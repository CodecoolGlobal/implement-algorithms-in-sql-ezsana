/*
 Functions that return the nth Fibonacci number
 Fibonacci sequence: 0, 1, 1, 2, 3, 5, 8, 13, 21, ...
 */

CREATE OR REPLACE FUNCTION nth_fib_with_while(n int) RETURNS int AS $$
    DECLARE
        fib_number_1 int := 0;
        fib_number_2 int := 1;
        counter int := 2;
    BEGIN
         if n <= 1 then
             RETURN 0;
         end if;
         while counter <= n loop
             counter := counter + 1;
             SELECT fib_number_2, fib_number_1+fib_number_2 INTO fib_number_1, fib_number_2;
         end loop;
         RETURN fib_number_1;
    END;
    $$
    LANGUAGE plpgsql;

CREATE FUNCTION nth_fib_with_loop(n integer) RETURNS integer AS $$
    DECLARE
        fib_number1 integer := 0;
        fib_number2 integer := 1;
        counter integer := 2;
        temp integer := 0;
    BEGIN
       if n <= 1 then RETURN 0; end if;
       loop
            temp = fib_number1;
            fib_number1 = fib_number2;
            fib_number2 = temp + fib_number2;
            EXIT WHEN counter = n;
            counter = counter+1;
       end loop;
       RETURN fib_number1;
    END;
    $$
    LANGUAGE plpgsql;

CREATE FUNCTION nth_fib_with_for(n integer) RETURNS integer AS $$
    DECLARE
        fib_number1 integer := 0;
        fib_number2 integer := 1;
        temp integer := 0;
    BEGIN
        if n <= 1 then RETURN 0; end if;
        for i in 2..n loop
            temp = fib_number1;
            fib_number1 = fib_number2;
            fib_number2 = temp + fib_number2;
        end loop;
        RETURN fib_number1;
    END;
    $$
    LANGUAGE plpgsql;