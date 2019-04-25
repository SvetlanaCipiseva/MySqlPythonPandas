-- 1. Find employees who have a first name that contain 'an'
SELECT first_name, last_name
FROM employees
WHERE first_name LIKE '%an%';

-- 2. Return a query that only shows first_name and last_name
SELECT first_name, last_name
FROM employees;

-- 3. Return a query that only returns users who's title is 'staff'
SELECT e.first_name, e.last_name, t.title
FROM titles t
LEFT JOIN employees e ON t.emp_no=e.emp_no
WHERE t.title='Staff';

-- 4. Return a query of all employees and arrange the results Ascending order
SELECT *
FROM employees
ORDER BY emp_no;

-- 5. Return a query that only returns the following First Name, Last Name, Salary and the department they belong to
SELECT e.first_name 'First Name', e.last_name 'Last Name', s.salary Salary, d.dept_name department
FROM employees e
JOIN  salaries  s ON e.emp_no=s.emp_no
JOIN dept_emp de ON e.emp_no=de.emp_no
JOIN departments d ON de.dept_no=d.dept_no
WHERE now() BETWEEN  s.from_date AND s.to_date
	AND now() BETWEEN  de.from_date AND de.to_date;