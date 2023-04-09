# RSA implementation 

## Made by Oleg Makeev | @BlaBlaHuman

### Usage: 

```
python3 rsa.py [MODE] [FLAGS...]
```

Modes and flags:

```
-h, --help					Print help

keygen						Generate a key pair for the algorithm

	-s BITS, 				[OPTIONAL] The size of q and p in bits, 
	--key_size BITS				1024 by default
	
	-pubf FILE_NAME,			[OPTIONAL] Name of the file to write the public key to,
	--public_key_file FILE_NAME		the key is written in the console by default
	
	-privf FILE_NAME,			[OPTIONAL] Name of the file to write the private key to,
	--private_key_file FILE_NAME 		the key is written in the console by default
	
	-h, --help				Print help

encrypt						Encrypt a message using the RSA algorithm

	-k FILE_NAME,				Name of the file containing the public key
	--keyfile FILE_NAME
	
	-if FILE_NAME,				Name of the file containing to encrypt
	--input_file FILE_NAME
	
	-of FILE_NAME,				Name of the file to write the encrypted message to
	--output_file FILE_NAME
	
	-h, --help				Print help
	

decrypt						Decrypt a message using the RSA algorithm

	-k FILE_NAME,				Name of the file containing the private key
	--keyfile FILE_NAME		
	
	-if FILE_NAME,				Name of the file to decrypt
	--input_file FILE_NAME
	
	-of FILE_NAME,				Name of the file to write the decrypted message to
	--output_file FILE_NAME
	
	-h, --help				Print help
	

```


### Examples

keygen:

```
$ python3 rsa.py keygen -s 10
Your public key: 433999-641831
Your private key: 227599-641831
```

```
$ python3 rsa.py keygen -s 100 -pubf public_key.txt -privf private_key.txt
Public key was written to public_key.txt
Private key was written to private_key.txt
```

```
$ python3 rsa.py keygen -s 100 -pubf public_key.txt
Public key was written to public_key.txt
Your private key: 227599-641831
```

```
$ python3 rsa.py keygen -s 100 -privf private_key.txt
Your public key: 433999-641831
Private key was written to private_key.txt
```

encrypt:

```
$ python3 rsa.py encrypt -k public_key.txt -if message.txt -of encrypted.txt
Message from message.txt was encrypted and written to encrypted.txt
```

decrypt:

```
$ python3 rsa.py decrypt -k private_key.txt -if encrypted.txt -of result.txt
Message from encrypted.txt was decrypted and written to result.txt
```

### Notes

Note that all keys `(f, s)` are read and written in the following format: `f-s`.
