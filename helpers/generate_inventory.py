#coding=utf-8
import random

if __name__ == '__main__':
    s = "INSERT INTO TABLE inventory (serial_number, rs_name) VALUES ({serial}, '{name}');"

    names = ['Небо-У', 'Гамма-С1Е', 'Противник-ГЕ', '5Н84А Оборона-14']

    for i in range(30):
        print(s.format(name=random.choice(names), serial=random.randint(1,10000000)))
