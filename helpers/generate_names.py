#coding=utf-8
import random

if __name__ == '__main__':
    s = "INSERT INTO personnel (surname, name, patronymic, status) VALUES ('{surname}', '{name}', '{patronymic}', 1);"

    names = ['Вадим', 'Иван', 'Пётр', 'Сергей', 'Анатолий', 'Михаил', 'Всеволод', 'Андрей', 'Геннадий', 'Валерий']
    surnames = ['Иванов', 'Петров', 'Гончаров', 'Сидоров', 'Ушаков', 'Чесноков', 'Горбачёв', 'Захаров', 'Соловьёв']
    patronymics = ['Иванович', 'Петрович', 'Сергеевич', 'Анатольевич', 'Денисович', 'Васильевич', 'Андреевич', 'Геннадиевич']

    for i in range(100):
        print(s.format(name=random.choice(names), surname=random.choice(surnames), patronymic=random.choice(patronymics)))
