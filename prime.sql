/*
 Function returns the nth prime number;
 */

CREATE OR REPLACE FUNCTION nth_prime(n int) RETURNS int AS $$
    DECLARE
        counter int;
        nth_prime_number int := 3;
        prime_numbers_counter int := 2;
    BEGIN
        if n < 1 then
            RETURN 0;
        end if;
        if n = 1 then
            RETURN 2;
        end if;
        if n = 2 then
            RETURN 3;
        end if;
        while prime_numbers_counter < n loop
            nth_prime_number := nth_prime_number + 1;
            counter := 0;
            for j in 2..|/nth_prime_number loop
                if nth_prime_number % j = 0 then
                    counter := counter + 1;
                    EXIT;
                end if;
            end loop;
            if counter = 0 then
                prime_numbers_counter := prime_numbers_counter + 1;
            end if;
        end loop;
        RETURN nth_prime_number;
    END;$$
    LANGUAGE plpgsql;