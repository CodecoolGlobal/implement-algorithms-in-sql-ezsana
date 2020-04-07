-- SQL statements that are used to define the soundex trigger
-- Include all your SQL statements:
--   - new table creation
--   - indexing creation
--   - stored procedure creation
--   - trigger creation
--   - SELECT statement for new search

CREATE EXTENSION fuzzystrmatch;

CREATE TABLE employee_soundex (
    soundex_id SERIAL PRIMARY KEY,
    employee_id int REFERENCES employees(employee_id),
    first_name_soundex varchar(4),
    last_name_soundex varchar(4)
);

INSERT INTO employee_soundex (employee_id, first_name_soundex, last_name_soundex)
SELECT employee_id, soundex(first_name), soundex(last_name) FROM employees;

-- Query results employee records with same soundex or searched name: works only for exact name match

CREATE OR REPLACE FUNCTION getEmployees(keyword varchar) RETURNS TABLE (
                                                                        employees_id employees.employee_id%TYPE,
                                                                        last_name employees.last_name%TYPE,
                                                                        first_name employees.first_name%TYPE,
                                                                        title employees.title%TYPE,
                                                                        title_of_courtesy employees.title_of_courtesy%TYPE,
                                                                        birth_date employees.birth_date%TYPE,
                                                                        hire_date employees.hire_date%TYPE
                                                                       ) AS $$
    BEGIN
        RETURN QUERY SELECT  e.employee_id, e.last_name, e.first_name, e.title, e.title_of_courtesy, e.birth_date, e.hire_date
        FROM employees e
        JOIN employee_soundex es
            on e.employee_id = es.employee_id
            WHERE (keyword ilike e.first_name OR keyword ilike e.last_name) OR (keyword = es.first_name_soundex OR keyword = es.last_name_soundex);
    END;
    $$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION name_to_soundex(first_name varchar, last_name varchar) RETURNS varchar[] AS $$
    DECLARE
        first_name_soundex varchar(4);
        last_name_soundex varchar(4);
        names varchar[];
    BEGIN
        SELECT soundex(first_name) INTO first_name_soundex;
        SELECT soundex(last_name) INTO last_name_soundex;
        names[0] := first_name_soundex;
        names[1] := last_name_soundex;
    RETURN names;
    END;
    $$
    LANGUAGE plpgsql;

--Update trigger functions:

CREATE OR REPLACE FUNCTION update_employees_soundex() RETURNS TRIGGER AS $$
    BEGIN
       UPDATE employee_soundex SET last_name_soundex = soundex(NEW.last_name), first_name_soundex = soundex(NEW.first_name)
       WHERE employee_soundex.employee_id = OLD.employee_id;
    RETURN NEW;
    END;
    $$
    LANGUAGE plpgsql;

CREATE TRIGGER use_soundex_on_update
    BEFORE UPDATE
    ON employees
    FOR EACH ROW
    EXECUTE PROCEDURE update_employees_soundex();

-- DELETE trigger functions:

CREATE OR REPLACE FUNCTION delete_from_employees_soundex() RETURNS TRIGGER AS $$
    BEGIN
       DELETE FROM employee_soundex WHERE employee_id = OLD.employee_id;
    RETURN OLD;
    END;
    $$
    LANGUAGE plpgsql;

CREATE TRIGGER use_soundex_on_deletion
    BEFORE DELETE
    ON employees
    FOR EACH ROW
    EXECUTE PROCEDURE delete_from_employees_soundex();

-- INSERT trigger functions:

CREATE OR REPLACE FUNCTION use_soundex() RETURNS TRIGGER AS $$
    DECLARE
        first_name varchar(255);
        last_name varchar(255);
        names varchar[];
    BEGIN
        SELECT employees.first_name INTO first_name FROM employees WHERE NEW.employee_id = employees.employee_id;
        SELECT employees.last_name INTO last_name FROM employees WHERE NEW.employee_id = employees.employee_id;
        SELECT name_to_soundex(first_name, last_name) INTO names;
        INSERT INTO employee_soundex (employee_id, first_name_soundex, last_name_soundex) VALUES(NEW.employee_id, names[0], names[1]);
    RETURN NEW;
    END;
    $$
    LANGUAGE plpgsql;

CREATE TRIGGER use_soundex_on_insertion
    AFTER INSERT
    ON employees
    FOR EACH ROW
    EXECUTE PROCEDURE use_soundex();

