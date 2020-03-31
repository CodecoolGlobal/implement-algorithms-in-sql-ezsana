/*
  PESEL (Polish Powszechny Elektroniczny System Ewidencji Ludności, Universal Electronic System for Registration of the Population)
  is the national identification number used in Poland since 1979. It always has 11 digits, identifies just one person and cannot be
  changed to another one (except some specific situations such as gender reassignment).
  PESEL number has the form of YYMMDDZZZXQ, where YYMMDD is the date of birth (with century encoded in month field), ZZZX is the
  personal identification number, where X codes sex (even number for females, odd number for males) and Q is a check digit,
  which is used to verify whether a given PESEL is correct or not.

  Example: Checking validity of PESEL 44051401358

  4*1 + 4*3 + 0*7 + 5*9 + 1*1 + 4*3 + 0*7 + 1*9 + 3*1 + 5*3 = 101

  The last digit of the result (101 modulo 10): 1

  The last digit is not 0 so, the checksum is 10 - 1 = 9

  9 is not equal to the last digit of PESEL, which is 8, so the PESEL number contains errors.
*/

CREATE OR REPLACE FUNCTION pesel(pesel_number bigint) RETURNS boolean AS $$
    DECLARE
        multipliers integer[10] := '{1, 3, 7, 9, 1, 3, 7, 9, 1, 3}';
        pesel_varchar varchar(11);
        last_pesel_number int;
        sum_of_pesel_number_digits int := 0;
        pesel_modulo int;
    BEGIN
        pesel_varchar := CAST(pesel_number AS varchar(11));
        last_pesel_number := right(pesel_varchar, 1);
        for counter in 1..10 loop
            sum_of_pesel_number_digits := sum_of_pesel_number_digits + CAST(substring(pesel_varchar, counter, 1) AS integer) * multipliers[counter];
        end loop;
    pesel_modulo = sum_of_pesel_number_digits % 10;
    raise notice 'Last digit: %. 10-modulo: %', last_pesel_number, 10 - pesel_modulo;
    RETURN last_pesel_number = 10 - pesel_modulo;
    EXCEPTION
        when SQLSTATE '22P02' then
            raise notice 'Number is invalid, please check.';
            RETURN false;
    END;$$
    LANGUAGE plpgsql;

-- VALID PESEL NUMBERS --
SELECT pesel(51042458999);
SELECT pesel(54051517859);
SELECT pesel(81112593983);
SELECT pesel(71122331899);
SELECT pesel(51050854521);
SELECT pesel(72032857518);
SELECT pesel(95042015174);
SELECT pesel(56122293851);
SELECT pesel(61111651422);
SELECT pesel(89073162648);
SELECT pesel(78092087366);

-- INVALID PESEL NUMBERS --
SELECT pesel(78101048163);
SELECT pesel(71031833225);
SELECT pesel(57112343496);
SELECT pesel(69072321360);
SELECT pesel(88101491561);
SELECT pesel(45050856232);