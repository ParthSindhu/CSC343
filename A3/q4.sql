SET SEARCH_PATH TO ticketchema,
    public;
DROP TABLE IF EXISTS q4 CASCADE;
-- Report the username of the person who has purchased the most tickets. If there is a tie, report them all.
CREATE TABLE q4(
    user_name VARCHAR(100),
    tickets_purchased INTEGER
);
-- Do this for each of the views that define your intermediate steps.
DROP VIEW IF EXISTS user_tickets CASCADE;
-- create views
-- users and their purchased tickets
CREATE VIEW user_tickets AS
SELECT user_name,
    COUNT(purchase_id) as tickets_purchased
FROM users
    NATURAL JOIN purchases
GROUP BY user_name;
-- insert into q4
INSERT INTO q4
SELECT user_name,
    tickets_purchased
FROM user_tickets
WHERE tickets_purchased = (
        SELECT MAX(tickets_purchased)
        FROM user_tickets
    );