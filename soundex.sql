-- SQL statements that are used to define the soundex function
-- Include all your tried solutions in the SQL file
-- with commenting below the functions the execution times on the tested dictionaries.

/*
    1. Retain the first letter of the name and drop all other occurrences of a, e, i, o, u, y, h, w.
    2. Replace consonants with digits as follows (after the first letter):
        * b, f, p, v → 1
        * c, g, j, k, q, s, x, z → 2
        * d, t → 3
        * l → 4
        * m, n → 5
        * r → 6
    3. If two or more letters with the same number are adjacent in the original name (before step 1),
        only retain the first letter; also two letters with the same number separated by 'h' or 'w' are
        coded as a single number, whereas such letters separated by a vowel are coded twice. This rule also
        applies to the first letter.
    4. If you have too few letters in your word that you can't assign three numbers, append with zeros until
        there are three numbers. If you have four or more numbers, retain only the first three.

 The following algorithm is followed by most SQL languages:

    1. Save the first letter. Map all occurrences of a, e, i, o, u, y, h, w. to zero(0)
    2. Replace all consonants (include the first letter) with digits as in [2.] above.
    3. Replace all adjacent same digits with one digit, and then remove all the zero (0) digits
    4. If the saved letter's digit is the same as the resulting first digit, remove the digit (keep the letter).
    5. Append 3 zeros if result contains less than 3 digits. Remove all except first letter and 3 digits after it (This step same as [4.] in explanation above).
 */

CREATE OR REPLACE FUNCTION soundex(name varchar) RETURNS varchar AS $$
   DECLARE
        first_letter varchar := left(name, 1);
        tempString varchar := '';
        arr varchar[];
        n varchar;
        arr2 varchar[];
        len_tempString integer;
    BEGIN
        SELECT into arr string_to_array(name, null);
        foreach n in array arr loop
            case n
                when 'a', 'e', 'i', 'o', 'u', 'y', 'h', 'w' then tempString = tempString || '0';
                when 'b', 'f', 'p', 'v' then tempString = tempString || '1';
                when 'c', 'g', 'j', 'k', 'q', 's', 'x', 'z' then tempString = tempString || '2';
                when 'd', 't' then tempString = tempString || '3';
                when 'l' then tempString = tempString || '4';
                when 'm', 'n' then tempString = tempString || '5';
                when 'r' then  tempString = tempString || '6';
            end case;
        end loop;
        len_tempString := length(tempString);
        SELECT INTO arr2 string_to_array(tempString, null);
        for i in 1..len_tempString-1 loop
            for j in i+1..len_tempString loop
                if arr2[i] <> '0' AND arr2[i] = arr2[j] then
                    arr2[j] := '0';
                elsif arr2[i] <> arr2[j] then
                    exit;
                end if;
            end loop;
        end loop;
        SELECT into tempString array_to_string(array_remove(arr2, '0'), '');
        case
            when substring(tempString, 2, 1) = '1' AND first_letter IN ('b', 'f', 'p', 'v') then tempString = substring(tempString, 1, 1) || substring(tempString, 3);
            when substring(tempString, 2, 1) = '2' AND first_letter IN ('c', 'g', 'j', 'k', 'q', 's', 'x', 'z') then tempString = substring(tempString, 1, 1) || substring(tempString, 3);
            when substring(tempString, 2, 1) = '3' AND first_letter IN ('d', 't') then tempString = substring(tempString, 1, 1) || substring(tempString, 3);
            when substring(tempString, 2, 1) = '4' AND first_letter IN ('l') then tempString = substring(tempString, 1, 1) || substring(tempString, 3);
            when substring(tempString, 2, 1) = '5' AND first_letter IN ('m', 'n') then tempString = substring(tempString, 1, 1) || substring(tempString, 3);
            when substring(tempString, 2, 1) = '6' AND first_letter IN ('r') then tempString = substring(tempString, 1, 1) || substring(tempString, 3);
        end case;
        if length(tempString) < 3 then
            tempString = tempString || '0' * (3-length(tempString));
        elsif length(tempString) > 4 then
            tempString = substring(tempString, 1, 3);
        end if;
        RETURN first_letter || tempString;
   end;
    $$
    LANGUAGE plpgsql;















