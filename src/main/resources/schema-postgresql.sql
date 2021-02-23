DROP TABLE IF EXISTS guest CASCADE;
DROP TABLE IF EXISTS reservation_guest CASCADE;
DROP TABLE IF EXISTS in_house_guest CASCADE;
DROP TABLE IF EXISTS room CASCADE;
DROP TABLE IF EXISTS room_status CASCADE;
DROP TABLE IF EXISTS reservation_req CASCADE;
DROP TABLE IF EXISTS rm_record CASCADE;
DROP TABLE IF EXISTS reserve_with CASCADE;
DROP TABLE IF EXISTS hotel_staff CASCADE;
DROP TABLE IF EXISTS receptionist CASCADE;
DROP TABLE IF EXISTS bill CASCADE;
DROP TABLE IF EXISTS services CASCADE;
DROP TABLE IF EXISTS charges CASCADE;
DROP TABLE IF EXISTS checked_in_out_rec CASCADE;
DROP TABLE IF EXISTS housekeep_record CASCADE;

CREATE TABLE guest (
    guest_id INT NOT NULL,
    name VARCHAR  NOT NULL,
    phone VARCHAR,
    PRIMARY KEY (guest_id)
);

INSERT INTO guest VALUES
(00001,'Lucy','696-535-6164'),
(00002,'James','345-100-7932'),
(00003,'Bob','923-344-1213'),
(00004,'Amanda','297-142-6267'),
(00005,'Tom','418-298-5989'),
(00006,'Edison','987-442-1632'),
(00007,'Charles','445-575-1484'),
(00008,'Richard','184-589-8844'),
(00009,'Julia','175-183-3661'),
(00010,'David','455-650-9440');

CREATE TABLE reservation_guest(
    guest_id INT NOT NULL,
    credit_card CHAR(30)  NOT NULL,
    photo_identity CHAR(30),
    email VARCHAR,
    membership CHAR(10),
    PRIMARY KEY (guest_id),
    UNIQUE (photo_identity, credit_card),
    FOREIGN KEY (guest_id) REFERENCES Guest(guest_id)
);

INSERT INTO reservation_guest VALUES
(00001,'36702422025519','392-39-7773','zdegiorgio9@edublogs.org',NULL),
(00002,'3577037006739620','778-21-0746','icaveya@youtube.com','NORMAL'),
(00003,'5602221789293420000','480-07-4246', 'cmcinallyb@sohu.com','VIP'),
(00004,'3563861329178490','556-21-8622','lcrossmanc@guardian.co.uk', NULL),
(00005,'201940347143160','392-39-7773','fcle@na.com','NORMAL');

CREATE TABLE in_house_guest(
    guest_id INT NOT NULL,
    PRIMARY KEY (guest_id),
    FOREIGN KEY (guest_id) REFERENCES guest(guest_id)
);

INSERT INTO in_house_guest VALUES
(00006),(00007),(00008),(00009),(00010);

CREATE TABLE room_status(
     status_id INT NOT NULL,
     available BOOLEAN NOT NULL,
     out_of_service BOOLEAN NOT NULL,
     clean BOOLEAN NOT NULL,
     occupied BOOLEAN NOT NULL,
     PRIMARY KEY (status_id),
     UNIQUE(out_of_service, occupied, clean)
);

INSERT INTO room_status VALUES
(1, true ,false,true,false),
(2, false,false,false,false),
(3, false,false,false,true),
(4, false,false,true,true ),
(5, false,true,false,false ),
(6, false,true,false,true ),
(7, false,true,true ,false ),
(8, false,true,true ,true );

CREATE TABLE room(
    rm_number INT NOT NULL,
    type VARCHAR NOT NULL,
    status_id INT,
    PRIMARY KEY (rm_number),
    FOREIGN KEY (status_id) REFERENCES room_status(status_id)
);
INSERT INTO room VALUES (101,'1BED', 1),(102, '2BED', 1),(103,'1BED',1),(104,'2BED',1),(105,'1BED',1);

CREATE TABLE reservation_req(
    rid INT,
    guest_id INT NOT NULL,
    m_date DATE NOT NULL,
    m_time TIME NOT NULL,
    req_code INT NOT NULL,
    req_status INT NOT NULL,
    date DATE NOT NULL,
    rm_number INT NOT NULL,
    UNIQUE (guest_id, date),
    PRIMARY KEY (rid),
    FOREIGN KEY (guest_id) REFERENCES reservation_guest(guest_id)
);

CREATE TABLE rm_record(
    rm_number INT NOT NULL,
    price INT NOT NULL,
    date DATE NOT NULL,
    last_req INT,
    PRIMARY KEY (rm_number, date),
    FOREIGN KEY (rm_number) REFERENCES room(rm_number),
    FOREIGN KEY (last_req) REFERENCES reservation_req(rid) ON DELETE SET NULL
);

CREATE TABLE reserve_with(
    rid INT,
    guest_id INT,
    PRIMARY KEY (rid, guest_id),
    FOREIGN KEY (rid) REFERENCES reservation_req(rid) ON DELETE CASCADE,
    FOREIGN KEY (guest_id) REFERENCES in_house_guest(guest_id) ON DELETE CASCADE
);


CREATE TABLE hotel_staff(
    sid INT,
    phone CHAR(50),
    name CHAR(20) NOT NULL,
    PRIMARY KEY (sid)
);

CREATE TABLE receptionist(
    sid INT,
    PRIMARY KEY (sid),
    FOREIGN KEY (sid) REFERENCES hotel_staff(sid)
);


INSERT INTO hotel_staff VALUES
(00001,'946-646-9159', 'Darci'),
(00002,'310-175-9817', 'Worden'),
(00003,'642-857-7383', 'Sander'),
(00004,'185-599-6769','Luce'),
(00005,'139-873-6306','Monica');

INSERT INTO receptionist VALUES (1),(2),(3),(4),(5);

CREATE TABLE housekeep_record(
kp_id INT,
date DATE NOT NULL ,
time TIME NOT NULL,
sid INT NOT NULL,
rm_number INT NOT NULL,
PRIMARY KEY (kp_id),
UNIQUE( date, time, sid),
FOREIGN KEY (sid) REFERENCES receptionist(sid),
FOREIGN KEY (rm_number) REFERENCES room(rm_number)
);

CREATE TABLE bill(
    bill_num INT NOT NULL,
    bill_date DATE NOT NULL,
    rm_number INT NOT NULL,
    date DATE NOT NULL,
    PRIMARY KEY (bill_num),
    UNIQUE (rm_number, date),
    FOREIGN KEY (rm_number, date) REFERENCES rm_record(rm_number,date)
);




CREATE TABLE services(
    service_id INT,
    service_name CHAR(20),
    description CHAR(60),
    fee INT,
    PRIMARY KEY (service_name)
);

INSERT INTO services VALUES
(00001,'full_clean','Linen replacement,vacuum,mop,dust,kitchen wipe,dishes', 90),
(00002,'partial_clean','Linen replacement,vacuum and mop', 45),
(00003,'lost_key','Guest lost their key', 25),
(00004,'lost_towel','Towel is missing from suite',10),
(00005,'water_bottle','Guest bought a water bottle',5);

CREATE TABLE charges(
    bill_num INT NOT NULL,
    cid INT,
    service_name CHAR(20),
    PRIMARY KEY (cid),
    FOREIGN KEY (bill_num) REFERENCES bill(bill_num),
    FOREIGN KEY (service_name) REFERENCES services(service_name)
);

CREATE TABLE checked_in_out_rec(
    ck_id INT,
    in_date DATE NOT NULL,
    in_time TIME NOT NULL,
    out_date DATE,
    out_time TIME,
    ck_in INT NOT NULL,
    ck_out INT,
    guest_id INT,
    rm_number INT,
    PRIMARY KEY (ck_id),
    UNIQUE (guest_id, in_date, in_time),
    UNIQUE (guest_id, out_date, out_time),
    FOREIGN KEY (guest_id) REFERENCES reservation_guest(guest_id),
    FOREIGN KEY (rm_number) REFERENCES room(rm_number),
    FOREIGN KEY (ck_in) REFERENCES receptionist(sid),
    FOREIGN KEY (ck_out) REFERENCES receptionist(sid),
    CHECK(out_date IS NULL OR out_date >= in_date)
);


INSERT INTO checked_in_out_rec VALUES
(1,current_date + 10, '08:00:00', NULL, NULL,1,NULL, 4, 104),
(2,current_date + 9, '08:00:00', NULL, NULL,1,NULL, 5, 105);


do '    declare
                       v_idx DATE := current_date - 1;
                    begin
                    while v_idx != current_date + 182 loop
                               v_idx := v_idx + 1;
                               insert into rm_record
                               values (101, 100 + (SELECT random()*(25-10)+10), v_idx, null),
                                      (102, 120 + (SELECT random()*(25-10)+10), v_idx, null),
                                      (103, 135 + (SELECT random()*(25-10)+10), v_idx, null),
                                      (104, 115 + (SELECT random()*(25-10)+10), v_idx, null),
                                      (105, 105 + (SELECT random()*(25-10)+10), v_idx, null);
                           end loop;
                  end; 'LANGUAGE PLPGSQL;

INSERT INTO bill VALUES
(00001,current_date + 3,101, current_date + 1),
(00002,current_date + 2,102, current_date + 2),
(00003,current_date + 5,103, current_date + 3),
(00004,current_date + 10,104, current_date + 9),
(00005,current_date + 10,105, current_date + 10);

INSERT INTO charges VALUES
(00001,00001, 'partial_clean'),
(00002,00002, 'lost_key'),
(00003,00003, 'lost_towel'),
(00004,00004,'lost_towel'),
(00005,00005,'water_bottle');

INSERT INTO reservation_req VALUES
(000010,00001,'2020-11-22','09:00',1,1,current_date + 3,101),
(000011,00002,'2020-11-23','10:00',1,1,current_date + 4,102),
(000012,00003,'2020-11-24','11:00',1,1,current_date + 5,103),
(000013,00004,'2020-11-25','12:00',1,1,current_date + 6,104),
(000014,00004,'2020-11-25','12:00',1,1,current_date + 7,104),
(000015,00005,'2020-11-25','12:00',1,1,current_date + 11,105);

INSERT INTO housekeep_record VALUES
(00001,current_date ,'09:00',00001, 101),
(00002,current_date + 1,'10:00',00002, 102),
(00003,current_date + 2,'11:00',00003, 103),
(00004,current_date + 3,'12:00',00004, 104),
(00005,current_date + 4,'14:00',00005, 105);

UPDATE rm_record
SET last_req = 10
WHERE rm_number = 101 AND date = current_date + 3;

UPDATE rm_record
SET last_req = 11
WHERE rm_number = 102 AND date = current_date + 4;

UPDATE rm_record
SET last_req = 12
WHERE rm_number = 103 AND date = current_date + 5;

UPDATE rm_record
SET last_req = 13
WHERE rm_number = 104 AND date = current_date + 6;

UPDATE rm_record
SET last_req = 14
WHERE rm_number = 104 AND date = current_date + 7;

UPDATE rm_record
SET last_req = 15
WHERE rm_number = 105 AND date = current_date + 41;


INSERT INTO checked_in_out_rec VALUES
(3,current_date + 3, '08:00:00', NULL, NULL,1,NULL, 1, 101),
(4,current_date + 4, '08:00:00', NULL, NULL,1,NULL, 2, 102),
(5,current_date + 5, '08:00:00', NULL, NULL,1,NULL, 3, 103),
(6,current_date + 6, '08:00:00', NULL, NULL,1,NULL, 4, 104),
(7,current_date + 11, '08:00:00', NULL, NULL,1,NULL, 5, 105);















