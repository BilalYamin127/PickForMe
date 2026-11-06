#!/usr/bin/env python3
"""Configure a privately transferred upload key without exposing passwords."""
import argparse
import base64
import getpass
import os
from pathlib import Path
import shutil
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--keystore', required=True, type=Path)
parser.add_argument('--alias', default='pickforme-upload')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
keystore = args.keystore.expanduser().resolve()
if not keystore.is_file():
    parser.error('Transfer the private keystore first; it is intentionally absent from GitHub.')
keytool = shutil.which('keytool')
if not keytool:
    parser.error('Install JDK 17 and add its bin directory to PATH.')
store_password = getpass.getpass('Keystore password: ')
key_password = getpass.getpass('Key password (Enter to use the keystore password): ') or store_password
env = os.environ.copy()
env['PICKFORME_VERIFY_STORE_PASSWORD'] = store_password
result = subprocess.run(
    [keytool, '-list', '-rfc', '-keystore', str(keystore), '-alias', args.alias,
     '-storepass:env', 'PICKFORME_VERIFY_STORE_PASSWORD'],
    env=env, capture_output=True, text=True,
)
if result.returncode:
    raise SystemExit('Cannot open the keystore/alias. Check the password and alias; nothing was written.')

def certificate_bytes(text):
    try:
        pem = text.split('-----BEGIN CERTIFICATE-----', 1)[1].split('-----END CERTIFICATE-----', 1)[0]
        return base64.b64decode(''.join(pem.split()), validate=True)
    except (ValueError, IndexError):
        raise SystemExit('The public signing certificate could not be read.')

if certificate_bytes(result.stdout) != certificate_bytes((root / 'release/upload-certificate.pem').read_text()):
    raise SystemExit('The keystore does not match this repository’s upload certificate. Use the matching backup.')

def property_value(value):
    return (value.replace('\\', '\\\\').replace('\n', '\\n').replace('\r', '\\r')
            .replace('\t', '\\t').replace(' ', '\\ ').replace('=', '\\=').replace(':', '\\:'))

path = root / 'android/key.properties'
values = {'storeFile': str(keystore), 'storePassword': store_password,
          'keyAlias': args.alias, 'keyPassword': key_password}
fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
with os.fdopen(fd, 'w') as output:
    for key, value in values.items():
        output.write(f'{key}={property_value(value)}\n')
path.chmod(0o600)
print('Upload certificate matches. Signing configured in ignored android/key.properties.')
