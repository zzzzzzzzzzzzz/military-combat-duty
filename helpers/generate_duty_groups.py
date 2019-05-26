#coding=utf-8
import random

if __name__ == '__main__':
    s = "INSERT INTO duty_groups (for_station) VALUES ('{name}');"

    names = ['Небо-У', 'Гамма-С1Е', 'Противник-ГЕ', '5Н84А Оборона-14']

    for i in range(10):
        print(s.format(name=random.choice(names)))
