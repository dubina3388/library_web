import '../models/author.dart';
import '../models/book.dart';
import '../models/reference.dart';

const seedGenres = [
  Genre(id: 1, name: 'Роман'),
  Genre(id: 2, name: 'Повесть'),
  Genre(id: 3, name: 'Поэзия'),
  Genre(id: 4, name: 'Драматургия'),
  Genre(id: 5, name: 'Фантастика'),
  Genre(id: 6, name: 'Детектив'),
];

const seedPublishers = [
  Publisher(id: 1, name: 'АСТ', city: 'Москва'),
  Publisher(id: 2, name: 'Эксмо', city: 'Москва'),
  Publisher(id: 3, name: 'Азбука', city: 'Санкт-Петербург'),
  Publisher(id: 4, name: 'Махаон', city: 'Москва'),
  Publisher(id: 5, name: 'Речь', city: 'Санкт-Петербург'),
];

const seedAuthors = [
  Author(id: 1, lastName: 'Толстой', firstName: 'Лев', middleName: 'Николаевич', country: 'Россия', birthYear: 1828),
  Author(id: 2, lastName: 'Достоевский', firstName: 'Фёдор', middleName: 'Михайлович', country: 'Россия', birthYear: 1821),
  Author(id: 3, lastName: 'Чехов', firstName: 'Антон', middleName: 'Павлович', country: 'Россия', birthYear: 1860),
  Author(id: 4, lastName: 'Пушкин', firstName: 'Александр', middleName: 'Сергеевич', country: 'Россия', birthYear: 1799),
  Author(id: 5, lastName: 'Булгаков', firstName: 'Михаил', middleName: 'Афанасьевич', country: 'Россия', birthYear: 1891),
  Author(id: 6, lastName: 'Брэдбери', firstName: 'Рэй', country: 'США', birthYear: 1920),
  Author(id: 7, lastName: 'Оруэлл', firstName: 'Джордж', country: 'Великобритания', birthYear: 1903),
  Author(id: 8, lastName: 'Кристи', firstName: 'Агата', country: 'Великобритания', birthYear: 1890),
  Author(id: 9, lastName: 'Ремарк', firstName: 'Эрих Мария', country: 'Германия', birthYear: 1898),
  Author(id: 10, lastName: 'Стругацкий', firstName: 'Аркадий', middleName: 'Натанович', country: 'Россия', birthYear: 1925),
  Author(id: 11, lastName: 'Стругацкий', firstName: 'Борис', middleName: 'Натанович', country: 'Россия', birthYear: 1933),
  Author(id: 12, lastName: 'Конан Дойл', firstName: 'Артур', country: 'Великобритания', birthYear: 1859),
];

const seedBooks = [
  Book(id: 1, title: 'Война и мир', isbn: '978-5-17-090334-1', year: 2019, pages: 1360, publisherId: 1, authorIds: [1], genreIds: [1], copiesTotal: 5, copiesAvailable: 3),
  Book(id: 2, title: 'Анна Каренина', isbn: '978-5-04-116751-3', year: 2021, pages: 864, publisherId: 2, authorIds: [1], genreIds: [1], copiesTotal: 4, copiesAvailable: 4),
  Book(id: 3, title: 'Преступление и наказание', isbn: '978-5-389-04922-6', year: 2020, pages: 592, publisherId: 3, authorIds: [2], genreIds: [1], copiesTotal: 6, copiesAvailable: 2),
  Book(id: 4, title: 'Идиот', isbn: '978-5-389-06473-1', year: 2018, pages: 640, publisherId: 3, authorIds: [2], genreIds: [1], copiesTotal: 3, copiesAvailable: 3),
  Book(id: 5, title: 'Братья Карамазовы', isbn: '978-5-17-087891-5', year: 2016, pages: 992, publisherId: 1, authorIds: [2], genreIds: [1], copiesTotal: 2, copiesAvailable: 1),
  Book(id: 6, title: 'Палата № 6', isbn: '978-5-04-098776-1', year: 2019, pages: 224, publisherId: 2, authorIds: [3], genreIds: [2], copiesTotal: 3, copiesAvailable: 3),
  Book(id: 7, title: 'Вишнёвый сад', isbn: '978-5-389-10563-2', year: 2017, pages: 160, publisherId: 3, authorIds: [3], genreIds: [4], copiesTotal: 4, copiesAvailable: 2),
  Book(id: 8, title: 'Евгений Онегин', isbn: '978-5-17-112233-7', year: 2022, pages: 288, publisherId: 1, authorIds: [4], genreIds: [3, 1], copiesTotal: 5, copiesAvailable: 5),
  Book(id: 9, title: 'Капитанская дочка', isbn: '978-5-353-09455-2', year: 2015, pages: 192, publisherId: 4, authorIds: [4], genreIds: [2], copiesTotal: 6, copiesAvailable: 4),
  Book(id: 10, title: 'Мастер и Маргарита', isbn: '978-5-389-01686-0', year: 2023, pages: 512, publisherId: 3, authorIds: [5], genreIds: [1, 5], copiesTotal: 7, copiesAvailable: 1),
  Book(id: 11, title: 'Собачье сердце', isbn: '978-5-04-121212-8', year: 2021, pages: 160, publisherId: 2, authorIds: [5], genreIds: [2, 5], copiesTotal: 4, copiesAvailable: 4),
  Book(id: 12, title: 'Белая гвардия', isbn: '978-5-17-098765-3', year: 2014, pages: 384, publisherId: 1, authorIds: [5], genreIds: [1], copiesTotal: 2, copiesAvailable: 2),
  Book(id: 13, title: '451 градус по Фаренгейту', isbn: '978-5-04-157843-2', year: 2022, pages: 256, publisherId: 2, authorIds: [6], genreIds: [5], copiesTotal: 6, copiesAvailable: 0),
  Book(id: 14, title: 'Марсианские хроники', isbn: '978-5-04-099354-0', year: 2020, pages: 320, publisherId: 2, authorIds: [6], genreIds: [5], copiesTotal: 3, copiesAvailable: 3),
  Book(id: 15, title: '1984', isbn: '978-5-17-080115-9', year: 2021, pages: 320, publisherId: 1, authorIds: [7], genreIds: [1, 5], copiesTotal: 8, copiesAvailable: 5),
  Book(id: 16, title: 'Скотный двор', isbn: '978-5-17-127342-6', year: 2019, pages: 192, publisherId: 1, authorIds: [7], genreIds: [2], copiesTotal: 3, copiesAvailable: 3),
  Book(id: 17, title: 'Убийство в «Восточном экспрессе»', isbn: '978-5-04-089123-4', year: 2018, pages: 256, publisherId: 2, authorIds: [8], genreIds: [6], copiesTotal: 4, copiesAvailable: 2),
  Book(id: 18, title: 'И никого не стало', isbn: '978-5-04-103030-7', year: 2020, pages: 288, publisherId: 2, authorIds: [8], genreIds: [6], copiesTotal: 5, copiesAvailable: 5),
  Book(id: 19, title: 'Три товарища', isbn: '978-5-17-105500-1', year: 2017, pages: 480, publisherId: 1, authorIds: [9], genreIds: [1], copiesTotal: 4, copiesAvailable: 3),
  Book(id: 20, title: 'На Западном фронте без перемен', isbn: '978-5-17-104201-8', year: 2023, pages: 320, publisherId: 1, authorIds: [9], genreIds: [1], copiesTotal: 3, copiesAvailable: 3),
  Book(id: 21, title: 'Пикник на обочине', isbn: '978-5-17-090111-0', year: 2016, pages: 256, publisherId: 1, authorIds: [10, 11], genreIds: [5], copiesTotal: 5, copiesAvailable: 4),
  Book(id: 22, title: 'Трудно быть богом', isbn: '978-5-17-077556-6', year: 2018, pages: 288, publisherId: 1, authorIds: [10, 11], genreIds: [5], copiesTotal: 4, copiesAvailable: 4),
  Book(id: 23, title: 'Понедельник начинается в субботу', isbn: '978-5-17-133445-9', year: 2024, pages: 320, publisherId: 5, authorIds: [10, 11], genreIds: [5], copiesTotal: 3, copiesAvailable: 1),
  Book(id: 24, title: 'Этюд в багровых тонах', isbn: '978-5-389-07432-7', year: 2015, pages: 224, publisherId: 3, authorIds: [12], genreIds: [6], copiesTotal: 2, copiesAvailable: 2),
  Book(id: 25, title: 'Собака Баскервилей', isbn: '978-5-353-08123-1', year: 2019, pages: 256, publisherId: 4, authorIds: [12], genreIds: [6], copiesTotal: 4, copiesAvailable: 3),
  Book(id: 26, title: 'Сказка о царе Салтане', isbn: '978-5-353-09876-5', year: 2021, pages: 64, publisherId: 4, authorIds: [4], genreIds: [3], copiesTotal: 6, copiesAvailable: 6),
];
