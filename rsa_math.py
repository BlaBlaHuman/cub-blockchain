import math
from secrets import randbits, SystemRandom

random = SystemRandom()


def is_prime(n: int) -> bool:
    if n == 2 or n == 3:
        return True

    if n % 2 == 0:
        return False

    k, r, s = 20, 0, n - 1

    while s % 2 == 0:
        r += 1
        s //= 2

    for _ in range(k):
        a = random.randrange(2, n - 1)
        x = pow(a, s, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
            if x == 1:
                return False
        else:
            return False

    return True


def generate_keys(number_of_bits: int) -> ((int, int), (int, int)):
    p = generate_prime(number_of_bits)
    q = generate_prime(number_of_bits)

    while p == q:
        q = generate_prime(number_of_bits)

    n = p * q
    phi = (p - 1) * (q - 1)

    d = random.randrange(2, phi)

    while math.gcd(d, phi) != 1:
        d = random.randrange(2, phi)

    e = pow(d, -1, phi)

    return (e, n), (d, n)


def generate_prime(number_of_bits: int) -> int:
    n = randbits(number_of_bits)
    while not is_prime(n):
        n = randbits(number_of_bits)
    return n
