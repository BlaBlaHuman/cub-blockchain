import argparse
from rsa_math import generate_keys
from io import TextIOWrapper


def write_key(key: (int, int), output_file: TextIOWrapper):
    (f, s) = key
    output_file.write(f'{f}-{s}')


def read_key(input_file: TextIOWrapper) -> (int, int):
    (f, s) = list(map(int, input_file.readline().split('-')))
    return f, s


def keygen_command(args: argparse.Namespace):
    (e, n), (d, n) = generate_keys(args.key_size)
    if args.public_key_file is not None:
        write_key((e, n), args.public_key_file)
        print(f'Public key was written to {args.public_key_file.name}')
    else:
        print(f'Your public key: {e}-{n}')

    if args.private_key_file is not None:
        write_key((d, n), args.private_key_file)
        print(f'Public key was written to {args.private_key_file.name}')
    else:
        print(f'Your private key: {d}-{n}')


def encrypt_command(args: argparse.Namespace):
    e, n = read_key(args.key_file)
    while byte := args.input_file.read(1):
        args.output_file.write(str(pow(ord(byte), e, n)) + "\n")
    print(f'Message from {args.input_file.name} was encrypted and written to {args.output_file.name}')


def decrypt_command(args: argparse.Namespace):
    d, n = read_key(args.key_file)
    for line in args.input_file.readlines():
        args.output_file.write(chr(pow(int(line), d, n)))
    print(f'Message from {args.input_file.name} was decrypted and written to {args.output_file.name}')
