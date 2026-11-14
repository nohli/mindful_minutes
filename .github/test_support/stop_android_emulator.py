#!/usr/bin/env python3
"""Record and finish this CI job's API 24 emulator shutdown."""
import json
import os
from pathlib import Path
import select
import signal
import subprocess
import sys


def snapshot(pid):
    root = Path('/proc') / str(pid)
    try:
        fields = (root / 'stat').read_text().rsplit(')', 1)[1].split()
        return {'pid': pid, 'start': fields[19], 'state': fields[0],
                'exe': str((root / 'exe').resolve(strict=True)), 'uid': root.stat().st_uid}
    except (FileNotFoundError, ProcessLookupError, PermissionError):
        return None


def fd_links(pid):
    links = {}
    try:
        for entry in (Path('/proc') / str(pid) / 'fd').iterdir():
            try:
                links[entry.name] = os.readlink(entry)
            except (FileNotFoundError, ProcessLookupError, PermissionError):
                continue
    except (FileNotFoundError, ProcessLookupError, PermissionError):
        pass
    return links


def console_sockets(port):
    sockets = set()
    for name in ('tcp', 'tcp6'):
        for line in (Path('/proc/net') / name).read_text().splitlines()[1:]:
            fields = line.split()
            if fields[3] == '0A' and int(fields[1].rsplit(':', 1)[1], 16) == int(port):
                sockets.add('socket:[' + fields[9] + ']')
    return sockets


def record_process(diagnostics, port):
    sdk = (Path(os.environ['ANDROID_HOME']) / 'emulator').resolve()
    sockets = console_sockets(port)
    matches = []
    for entry in Path('/proc').iterdir():
        if not entry.name.isdigit():
            continue
        record = snapshot(int(entry.name))
        if (record is not None and record['uid'] == os.getuid()
                and Path(record['exe']).name.startswith('qemu-system-')
                and Path(record['exe']).is_relative_to(sdk)
                and sockets.intersection(fd_links(record['pid']).values())):
            matches.append(record)
    payload = {'record': matches[0] if len(matches) == 1 else None,
               'matching_pids': [record['pid'] for record in matches]}
    with (diagnostics / 'emulator-process.json').open('x') as stream:
        json.dump(payload, stream, indent=2)
    return 0 if payload['record'] is not None else 1


def stop_process(diagnostics, port):
    record = json.loads((diagnostics / 'emulator-process.json').read_text())['record']
    evidence = {'exited': False}
    pidfd = None
    try:
        if record is None:
            raise RuntimeError('Emulator ownership was not established; no process signaled')
        try:
            pidfd = os.pidfd_open(record['pid'])
        except ProcessLookupError:
            evidence['exited'] = True
            return 0
        poller = select.poll()
        poller.register(pidfd, select.POLLIN)

        def has_exited(seconds):
            return any(events & (select.POLLIN | select.POLLHUP)
                       for _, events in poller.poll(seconds * 1000))

        if has_exited(0):
            evidence['exited'] = True
            return 0
        current = snapshot(record['pid'])
        if current is None or any(current[key] != record[key] for key in ('start', 'exe', 'uid')):
            if has_exited(0):
                evidence['exited'] = True
                return 0
            raise RuntimeError('Live emulator identity is unverified; no process signaled')
        evidence['before_shutdown'] = current
        evidence['pipes_before'] = {key: value for key, value in fd_links(record['pid']).items()
                                    if key in ('1', '2')}
        if console_sockets(port).intersection(fd_links(record['pid']).values()):
            try:
                result = subprocess.run(['adb', '-s', 'emulator-' + port, 'emu', 'kill'],
                                        capture_output=True, text=True, timeout=10)
                evidence['adb_kill'] = {'exit': result.returncode, 'stdout': result.stdout,
                                        'stderr': result.stderr}
            except subprocess.TimeoutExpired:
                evidence['adb_kill'] = {'timeout_seconds': 10}
        evidence['after_shutdown_ack'] = snapshot(record['pid'])
        evidence['pipes_after'] = {key: value for key, value in fd_links(record['pid']).items()
                                   if key in ('1', '2')}
        for sig, seconds in ((None, 10), (signal.SIGTERM, 5), (signal.SIGKILL, 5)):
            if sig is not None:
                try:
                    signal.pidfd_send_signal(pidfd, sig)
                    evidence.setdefault('signals', []).append(sig.name)
                except ProcessLookupError:
                    evidence['exited'] = True
                    break
            if has_exited(seconds):
                evidence['exited'] = True
                break
        if not evidence['exited']:
            evidence['error'] = 'Job-owned emulator did not exit after bounded shutdown'
    except (OSError, RuntimeError) as error:
        evidence['error'] = str(error)
    finally:
        with (diagnostics / 'emulator-shutdown.json').open('x') as stream:
            json.dump(evidence, stream, indent=2)
        if pidfd is not None:
            os.close(pidfd)
    return 0 if evidence['exited'] else 1


if __name__ == '__main__':
    mode, directory, port = sys.argv[1:]
    operation = {'record': record_process, 'stop': stop_process}[mode]
    sys.exit(operation(Path(directory), port))
