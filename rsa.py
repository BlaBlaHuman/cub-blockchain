import argparse
from commands_handler import keygen_command, encrypt_command, decrypt_command


def parse_arguments():
    main_parser = argparse.ArgumentParser(description="RSA implementation by Oleg Makeev | @BlaBlaHuman")

    commands_parser = main_parser.add_subparsers(required=True)

    # Subparser for `keygen` command
    keygen_parser = commands_parser.add_parser("keygen", help="Generate a key pair")
    keygen_parser.add_argument("-s", "--key_size",
                               type=int,
                               default=1024,
                               help="[OPTIONAL] The size of q and p in bits, 1024 by default")
    keygen_parser.add_argument("-pubf", "--public_key_file",
                               type=argparse.FileType('w+'),
                               help="[OPTIONAL] Name of the file to write the public key to")
    keygen_parser.add_argument("-privf", "--private_key_file",
                               type=argparse.FileType('w+'),
                               help="[OPTIONAL] Name of the file to write the private key to")
    keygen_parser.set_defaults(func=keygen_command)

    # Subparser for `encrypt` command
    encrypt_parser = commands_parser.add_parser("encrypt", help="Encrypt a message using the RSA algorithm")
    encrypt_parser.add_argument("-k", "--key_file",
                                type=argparse.FileType('r'),
                                help="Name of the file containing the public key",
                                required=True)
    encrypt_parser.add_argument("-if", "--input_file",
                                type=argparse.FileType('r'),
                                help="Name of the file to encrypt",
                                required=True)
    encrypt_parser.add_argument("-of", "--output_file",
                                type=argparse.FileType('w+'),
                                help="Name of the file to write the encrypted message to",
                                required=True)
    encrypt_parser.set_defaults(func=encrypt_command)

    # Subparser for `decrypt` command
    decrypt_parser = commands_parser.add_parser("decrypt", help="Decrypt a message using the RSA algorithm")
    decrypt_parser.add_argument("-k", "--key_file",
                                type=argparse.FileType('r'),
                                help="Name of the file containing the private key",
                                required=True)
    decrypt_parser.add_argument("-if", "--input_file",
                                type=argparse.FileType('r'),
                                help="Name of the file to decrypt",
                                required=True)
    decrypt_parser.add_argument("-of", "--output_file",
                                type=argparse.FileType('w+'),
                                help="Name of the file to write the decrypted message to",
                                required=True)
    decrypt_parser.set_defaults(func=decrypt_command)

    arguments = main_parser.parse_args()
    arguments.func(arguments)


if __name__ == "__main__":
    parse_arguments()
