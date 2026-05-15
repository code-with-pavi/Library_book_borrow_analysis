-- ===== Library Borrowing Analytics Project =====

-- ===== Create Tables =====
CREATE DATABASE `LIBRARY` ;
USE `LIBRARY` ;

CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(100),
    author VARCHAR(100),
    genre VARCHAR(50),
    published_year INT
);

CREATE TABLE members (
    member_id INT PRIMARY KEY,
    name VARCHAR(100),
    join_date DATE,
    age INT,
    gender VARCHAR(10)
);

CREATE TABLE borrowings (
    borrow_id INT PRIMARY KEY,
    book_id INT,
    member_id INT,
    borrow_date DATE,
    due_date DATE,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

INSERT IGNORE INTO books (book_id, title, author, genre, published_year) VALUES
(1, 'The Silent Patient', 'Alex Michaelides', 'Thriller', 2019),
(2, 'Educated', 'Tara Westover', 'Memoir', 2018),
(3, 'Becoming', 'Michelle Obama', 'Biography', 2018),
(4, 'Atomic Habits', 'James Clear', 'Self-help', 2018),
(5, '1984', 'George Orwell', 'Dystopian', 1949),
(6, 'To Kill a Mockingbird', 'Harper Lee', 'Classic', 1960),
(7, 'The Great Gatsby', 'F. Scott Fitzgerald', 'Classic', 1925),
(8, 'Sapiens', 'Yuval Noah Harari', 'History', 2011),
(9, 'The Power of Habit', 'Charles Duhigg', 'Self-help', 2012),
(10, 'The Hobbit', 'J.R.R. Tolkien', 'Fantasy', 1937);

INSERT INTO members (member_id, name, join_date, age, gender) VALUES
(1, 'Nishrath', '2021-06-01', 23, 'F'),
(2, 'Shakeel', '2020-11-15', 30, 'M'),
(3, 'Pavithra', '2022-01-20', 27, 'F'),
(4, 'Sachin', '2019-08-10', 35, 'M'),
(5, 'Sriyaa', '2023-03-05', 22, 'F'),
(6, 'Sridhar', '2022-12-01', 28, 'M');

INSERT INTO borrowings (borrow_id, book_id, member_id, borrow_date, due_date, return_date) VALUES
(101, 1, 1, '2023-07-01', '2023-07-10', '2023-07-12'),
(102, 2, 1, '2023-08-15', '2023-08-25', '2023-08-24'),
(103, 3, 2, '2023-06-10', '2023-06-20', '2023-06-18'),
(104, 4, 3, '2023-09-01', '2023-09-11', NULL),
(105, 5, 4, '2023-07-22', '2023-08-01', '2023-08-05'),
(106, 6, 5, '2023-05-10', '2023-05-20', '2023-05-19'),
(107, 7, 6, '2023-06-15', '2023-06-25', '2023-06-30'),
(108, 8, 1, '2023-09-05', '2023-09-15', NULL),
(109, 9, 2, '2023-07-01', '2023-07-11', '2023-07-11'),
(110, 10, 3, '2023-07-15', '2023-07-25', '2023-07-20'),
(111, 1, 4, '2023-08-01', '2023-08-11', '2023-08-09'),
(112, 2, 5, '2023-09-10', '2023-09-20', NULL),
(113, 3, 6, '2023-09-12', '2023-09-22', NULL),
(114, 4, 1, '2023-09-15', '2023-09-25', NULL),
(115, 5, 2, '2023-08-20', '2023-08-30', '2023-09-02');

-- ===== Analysis Queries =====

-- Total number of books
SELECT COUNT(*) AS total_books
FROM books
;

-- Total number of members
SELECT COUNT(*) AS total_members
FROM members
;

-- Most borrowed books
SELECT book.title, COUNT(*) AS times_borrowed
FROM borrowings AS br
JOIN books AS book
 ON br.book_id = book.book_id
GROUP BY book.title
ORDER BY times_borrowed DESC
LIMIT 10;

-- Gender distribution of members
SELECT gender, COUNT(*) AS total_members
FROM members
GROUP BY gender;

-- Average borrowing duration (in days)
SELECT AVG(DATEDIFF(return_date, borrow_date)) AS avg_borrow_duration
FROM borrowings
WHERE return_date IS NOT NULL;

-- Books not borrowed in the last 6 months
SELECT title
FROM books
WHERE book_id NOT IN (
    SELECT DISTINCT book_id
    FROM borrowings
    WHERE borrow_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
);

-- Overdue returns report
SELECT mem.name, book.title, br.due_date, br.return_date,
       DATEDIFF(br.return_date, br.due_date) AS days_late
FROM borrowings AS br
JOIN members AS mem
 ON br.member_id = mem.member_id
JOIN books AS book
 ON br.book_id = book.book_id
WHERE br.return_date > br.due_date
;

-- Fine calculation (₹15 per late day)
SELECT br.borrow_id, mem.name, book.title,
       GREATEST(0, DATEDIFF(br.return_date, br.due_date)) * 15 AS fine_amount
FROM borrowings br
JOIN members AS mem
 ON br.member_id = mem.member_id
JOIN books book 
 ON br.book_id = book.book_id
WHERE br.return_date IS NOT NULL
;

-- Top 10 readers by borrow count
SELECT mem.name, COUNT(*) AS total_borrowed
FROM borrowings br
JOIN members mem 
 ON br.member_id = mem.member_id
GROUP BY mem.name
ORDER BY total_borrowed DESC
LIMIT 10
;

-- Monthly borrowing 
SELECT DATE_FORMAT(borrow_date, '%Y-%m') AS month, COUNT(*) AS total_borrowings
FROM borrowings AS br
GROUP BY month
ORDER BY month
;

-- Hoarder detection: Members borrowing more than 5 books in a single month
SELECT member_id, COUNT(*) AS books_borrowed, DATE_FORMAT(borrow_date, '%Y-%m') AS month
FROM borrowings AS br
GROUP BY member_id, month
HAVING books_borrowed > 5;
