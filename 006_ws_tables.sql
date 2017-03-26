CREATE TABLESPACE ws_data_ts 
DATAFILE  'c:\temp\ws_data_df_01.dbf' 
SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE 1000M
ONLINE;

CREATE ROLE ws_owner_rol;

GRANT CREATE SESSION TO ws_owner_rol;
GRANT CREATE SEQUENCE TO ws_owner_rol;
GRANT CREATE TABLE TO ws_owner_rol;
GRANT CREATE TRIGGER TO ws_owner_rol;
GRANT CREATE VIEW TO ws_owner_rol;
GRANT CREATE PROCEDURE TO ws_owner_rol;
grant execute on sys.DBMS_SQL to ws_owner_rol;


CREATE USER ws_owner
  IDENTIFIED BY "ws_owner_123"
  DEFAULT TABLESPACE ws_data
  TEMPORARY TABLESPACE TEMP
  PROFILE default
  ACCOUNT UNLOCK;

ALTER USER ws_owner QUOTA UNLIMITED ON ws_data;

GRANT ws_owner_rol TO ws_owner;


-- Now login as ws_owner and create below objects.


DROP TABLE ws_work_ordr_servc_stts_p;
DROP TABLE ws_work_ordr_schedl_m;
DROP TABLE ws_work_ordr_servc_p;
DROP TABLE ws_work_ordr_m;
DROP TABLE ws_work_ordr_servc_stts_r;
DROP TABLE ws_work_ordr_stts_r;
DROP TABLE ws_servc_specialst_m;
DROP TABLE ws_servc_m;
DROP TABLE ws_emp_m;
DROP TABLE ws_cust_elec_contact_m;
DROP TABLE ws_contact_typ_r;
DROP TABLE ws_cust_physcl_addr_m;
DROP TABLE ws_cust_m;
DROP TABLE ws_compny_r;
DROP SEQUENCE ws_woss_id_sq;
DROP SEQUENCE ws_wos_id_sq;
DROP SEQUENCE ws_work_ordr_schedl_id_sq;
DROP SEQUENCE ws_wo_servc_id_sq;
DROP SEQUENCE ws_work_ordr_id_sq;
DROP SEQUENCE ws_emp_id_sq;
DROP SEQUENCE ws_cust_elec_contact_id_sq;
DROP SEQUENCE ws_cust_physcl_addr_id_sq;
DROP SEQUENCE ws_cust_id_sq;
CREATE SEQUENCE ws_cust_id_sq START WITH 1001 MAXVALUE 9999;
CREATE SEQUENCE ws_cust_physcl_addr_id_sq START WITH 10000001 MAXVALUE 99999999;
CREATE SEQUENCE ws_cust_elec_contact_id_sq START WITH 10000001 MAXVALUE 99999999;
CREATE SEQUENCE ws_emp_id_sq START WITH 101 MAXVALUE 999;
CREATE SEQUENCE ws_work_ordr_id_sq START WITH 10001 MAXVALUE 99999;
CREATE SEQUENCE ws_wo_servc_id_sq START WITH 100001 MAXVALUE 999999;
CREATE SEQUENCE ws_work_ordr_schedl_id_sq START WITH 1000001 MAXVALUE 9999999;
CREATE SEQUENCE ws_wos_id_sq START WITH 10000001 MAXVALUE 99999999;
CREATE SEQUENCE ws_woss_id_sq START WITH 10000001 MAXVALUE 99999999;
CREATE TABLE ws_compny_r
/* This table will only have one record
If a specific field has to be updated, then the trigger needs to be disabled, so the specific field can be updated.
One the update is completed, make sure there is only one row, and enable the trigger.
*/
(
  compny_legl_nm                VARCHAR2(32) NOT NULL
 ,compny_begn_dt                DATE NOT NULL
 ,compny_desc                   VARCHAR2(512) NOT NULL
 ,compny_email_addr             VARCHAR2(64) NOT NULL
 ,CONSTRAINT ws_compny_r_pk PRIMARY KEY(compny_legl_nm)
);
INSERT INTO ws_compny_r
VALUES ('V Services'
       ,TO_DATE('20150101'
               ,'YYYYMMDD')
       ,'Provides various services'
       ,'contact@tempvservices.com');
CREATE OR REPLACE TRIGGER ws_compny_r_bs
  BEFORE INSERT OR UPDATE OR DELETE
  ON ws_compny_r
BEGIN
  IF INSERTING THEN
    raise_application_error(-20001
                           ,'No inserts from the table');
  ELSIF UPDATING THEN
    raise_application_error(-20002
                           ,'No updates from the table');
  ELSIF DELETING THEN
    raise_application_error(-20003
                           ,'No deletes from the table');
  END IF;
END;
/
CREATE TABLE ws_work_ordr_stts_r
/*
This table specifies various possible statuses for a Work order.
Under one work order there can be multiple service requests.
*/
(
  work_ordr_stts_cd             VARCHAR2(8) NOT NULL
 ,work_ordr_stts_nm             VARCHAR2(64) NOT NULL
 ,CONSTRAINT ws_work_ordr_stts_r_pk PRIMARY KEY(work_ordr_stts_cd)
 ,CONSTRAINT ws_work_ordr_stts_r_uk01 UNIQUE(work_ordr_stts_nm)
);
INSERT INTO ws_work_ordr_stts_r
VALUES ('WO-NOSH'
       ,'Work order not scheduled');
INSERT INTO ws_work_ordr_stts_r
VALUES ('WO-CNCL'
       ,'Work order Canceled');
INSERT INTO ws_work_ordr_stts_r
VALUES ('WO-SCH'
       ,'Work order Scheduled, but not started');
INSERT INTO ws_work_ordr_stts_r
VALUES ('WO-BEGN'
       ,'Work order Started');
INSERT INTO ws_work_ordr_stts_r
VALUES ('WO-ENDD'
       ,'Work order Finished');
CREATE TABLE ws_work_ordr_servc_stts_r
/*
This table specifies various possible statuses for a given service under a work order.
*/
(
  work_ordr_servc_stts_cd       VARCHAR2(8) NULL
 ,work_ordr_servc_stts_nm       VARCHAR2(64) NOT NULL
 ,CONSTRAINT ws_work_ordr_servc_stts_r_pk PRIMARY KEY(work_ordr_servc_stts_cd)
 ,CONSTRAINT ws_work_ordr_servc_stts_r_uk01 UNIQUE(work_ordr_servc_stts_nm)
);
INSERT INTO ws_work_ordr_servc_stts_r
VALUES ('WOS-NOSH'
       ,'Service not scheduled');
INSERT INTO ws_work_ordr_servc_stts_r
VALUES ('WOS-CNCL'
       ,'Service Canceled');
INSERT INTO ws_work_ordr_servc_stts_r
VALUES ('WOS-SCH'
       ,'Service Scheduled, but not started');
INSERT INTO ws_work_ordr_servc_stts_r
VALUES ('WOS-BEGN'
       ,'Service Started');
INSERT INTO ws_work_ordr_servc_stts_r
VALUES ('WOS-ENDD'
       ,'Service Finished');
CREATE TABLE ws_contact_typ_r
/*
This is a reference table, that lists possible contact types of a customer.
*/
(
  contact_typ_cd                VARCHAR2(4) NOT NULL CONSTRAINT ws_contact_typ_r_pk PRIMARY KEY
 ,contact_typ_nm                VARCHAR2(32) NOT NULL CONSTRAINT ws_contact_typ_r_uk01 UNIQUE
);
INSERT INTO ws_contact_typ_r
VALUES ('CELL'
       ,'Cell phone');
INSERT INTO ws_contact_typ_r
VALUES ('LAND'
       ,'Land phone');
INSERT INTO ws_contact_typ_r
VALUES ('EMAL'
       ,'Email');
INSERT INTO ws_contact_typ_r
VALUES ('FAX'
       ,'Fax');
CREATE TABLE ws_cust_m
/*
This table contains one record per customer
We will never delete records from this table.
*/
(
  cust_id                       NUMBER(4) NOT NULL
 ,cust_legl_nm                  VARCHAR2(32) NOT NULL
 ,begin_dt                      DATE NOT NULL
 ,CONSTRAINT ws_cust_m_pk PRIMARY KEY(cust_id)
);
CREATE OR REPLACE TRIGGER ws_cust_m_br
  BEFORE INSERT OR UPDATE OR DELETE
  ON ws_cust_m
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.cust_id               := ws_cust_id_sq.NEXTVAL;
  ELSIF UPDATING THEN
    :new.cust_id               := :old.cust_id;
  ELSIF DELETING THEN
    raise_application_error(-20001
                           ,'No deletes from the table');
  END IF;
END;
/
CREATE TABLE ws_cust_physcl_addr_m
/*
this lists only one active address per customer at any given point.
*/
(
  cust_physcl_addr_id           NUMBER(8) CONSTRAINT ws_cust_addr_m_pk PRIMARY KEY
 ,cust_id                       CONSTRAINT ws_cust_addr_m_fk01 REFERENCES ws_cust_m(cust_id)
 ,addr_ln_1                     VARCHAR2(40) NOT NULL
 ,addr_ln_2                     VARCHAR2(40)
 ,city_nm                       VARCHAR2(32) NOT NULL
 ,state_cd                      VARCHAR2(2)
 ,postl_cd                      VARCHAR2(6)
 ,activ_yn                      VARCHAR2(1) CHECK(activ_yn IN ('Y', 'N'))
);
CREATE UNIQUE INDEX ws_cust_physcl_addr_m_ux01
  ON ws_cust_physcl_addr_m(CASE activ_yn WHEN 'Y' THEN cust_id END);
CREATE OR REPLACE TRIGGER ws_cust_physcl_addr_m_br
  BEFORE INSERT OR UPDATE OR DELETE
  ON ws_cust_physcl_addr_m
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.cust_physcl_addr_id   := ws_cust_physcl_addr_id_sq.NEXTVAL;
  ELSIF UPDATING THEN
    :new.cust_physcl_addr_id   := :old.cust_physcl_addr_id;
  ELSIF DELETING THEN
    raise_application_error(-20001
                           ,'Deletes are not permitted, instead update activ_yn indicator');
  END IF;
END;
/
CREATE TABLE ws_cust_elec_contact_m
/*
This table contain all possible contacts for each customer.
*/
(
  cust_elec_contact_id          NUMBER(8) CONSTRAINT ws_cust_elec_addr_m_pk PRIMARY KEY
 ,cust_id                       CONSTRAINT ws_cust_elec_addr_m_fk01 REFERENCES ws_cust_m(cust_id)
 ,contact_typ_cd                VARCHAR2(4)
 ,elec_contact_addr             VARCHAR2(64)
 ,activ_yn                      VARCHAR2(1)
);
CREATE OR REPLACE TRIGGER ws_cust_elec_contact_m_br
  BEFORE INSERT OR UPDATE OR DELETE
  ON ws_cust_elec_contact_m
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.cust_elec_contact_id  := ws_cust_elec_contact_id_sq.NEXTVAL;
  ELSIF UPDATING THEN
    :new.cust_elec_contact_id  := :old.cust_elec_contact_id;
  ELSIF DELETING THEN
    raise_application_error(-20001
                           ,'Deletes are not permitted, instead update activ_yn indicator');
  END IF;
END;
/
CREATE TABLE ws_emp_m
/*
This contain one record per employee
*/
(
  emp_id                        NUMBER(3) NULL
 ,emp_legl_nm                   VARCHAR2(32) NOT NULL
 ,emp_begn_dt                   DATE NOT NULL
 ,emp_email_addr                VARCHAR2(64) NOT NULL
 ,CONSTRAINT ws_emp_m_pk PRIMARY KEY(emp_id)
);
CREATE OR REPLACE TRIGGER ws_emp_m_br
  BEFORE INSERT OR UPDATE OR DELETE
  ON ws_emp_m
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.emp_id                := ws_emp_id_sq.NEXTVAL;
  ELSIF UPDATING THEN
    :new.emp_id                := :old.emp_id;
  ELSIF DELETING THEN
    raise_application_error(-20001
                           ,'No deletes from the table');
  END IF;
END;
/
CREATE TABLE ws_servc_m
/*
This table contains all possible services that the company offers.
*/
(
  servc_cd                      VARCHAR2(8) NULL
 ,servc_nm                      VARCHAR2(32) NOT NULL
 ,servc_begn_dt                 DATE NOT NULL
 ,servc_hrs_cnt                 NUMBER(2)
 ,unit_cost_amt                 NUMBER(6, 2)
 ,CONSTRAINT ws_servc_m_pk PRIMARY KEY(servc_cd)
 ,CONSTRAINT ws_servc_m__uk01 UNIQUE(servc_nm)
);
CREATE OR REPLACE TRIGGER ws_servc_m_br
  BEFORE INSERT OR UPDATE OR DELETE
  ON ws_servc_m
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.servc_cd              := UPPER(:new.servc_cd);
  ELSIF UPDATING THEN
    :new.servc_cd              := :old.servc_cd;
  ELSIF DELETING THEN
    raise_application_error(-20001
                           ,'No deletes from the table');
  END IF;
END;
/
CREATE TABLE ws_servc_specialst_m
(
  servc_cd                      VARCHAR2(8) NOT NULL
 ,emp_id                        NUMBER(3) NOT NULL
 ,begn_dt                       DATE NOT NULL
 ,CONSTRAINT ws_servc_specialst_m_pk PRIMARY KEY(servc_cd, emp_id)
 ,CONSTRAINT ws_servc_specialst_m_fk01 FOREIGN KEY(servc_cd) REFERENCES ws_servc_m(servc_cd)
 ,CONSTRAINT ws_servc_specialst_m_fk02 FOREIGN KEY(emp_id) REFERENCES ws_emp_m(emp_id)
);
CREATE TABLE ws_work_ordr_m
(
  work_ordr_id                  NUMBER(5) NOT NULL
 ,cust_id                       NUMBER(4) NOT NULL
 ,work_ordr_dtm                 DATE NOT NULL
 ,work_ordr_stts_cd             VARCHAR2(8) NOT NULL
 ,CONSTRAINT ws_work_ordr_m_pk PRIMARY KEY(work_ordr_id)
 ,CONSTRAINT ws_work_ordr_m_fk01 FOREIGN KEY(cust_id) REFERENCES ws_cust_m(cust_id)
 ,CONSTRAINT ws_work_ordr_m_fk02 FOREIGN KEY(work_ordr_stts_cd) REFERENCES ws_work_ordr_stts_r(work_ordr_stts_cd)
);
CREATE OR REPLACE TRIGGER ws_work_ordr_m_br
  BEFORE INSERT OR UPDATE OR DELETE
  ON ws_work_ordr_m
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.work_ordr_id          := ws_work_ordr_id_sq.NEXTVAL;
  ELSIF UPDATING THEN
    NULL;
  ELSIF DELETING THEN
    NULL;
  END IF;
END;
/
CREATE TABLE ws_work_ordr_servc_p
(
  wo_servc_id                   NUMBER(6) NOT NULL
 ,work_ordr_id                  NUMBER(5) NOT NULL
 ,servc_cd                      VARCHAR2(8) NOT NULL
 ,reqstd_begn_dtm               DATE NOT NULL
 ,reqstd_hrs_cnt                NUMBER NOT NULL
 ,CONSTRAINT ws_work_ordr_servc_p_pk PRIMARY KEY(wo_servc_id)
 ,CONSTRAINT ws_work_ordr_servc_p_uk01 UNIQUE(work_ordr_id, servc_cd)
 ,CONSTRAINT ws_work_ordr_servc_p_fk01 FOREIGN KEY(work_ordr_id) REFERENCES ws_work_ordr_m(work_ordr_id)
 ,CONSTRAINT ws_work_ordr_servc_p_fk02 FOREIGN KEY(servc_cd) REFERENCES ws_servc_m(servc_cd)
);
CREATE OR REPLACE TRIGGER ws_work_ordr_servc_p_br
  BEFORE INSERT OR UPDATE OR DELETE
  ON ws_work_ordr_servc_p
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.wo_servc_id           := ws_wo_servc_id_sq.NEXTVAL;
  ELSIF UPDATING THEN
    NULL;
  ELSIF DELETING THEN
    NULL;
  END IF;
END;
/
CREATE TABLE ws_work_ordr_schedl_m
(
  wos_id                        NUMBER(8) NOT NULL
 ,work_ordr_id                  NUMBER(5) NOT NULL
 ,servc_cd                      VARCHAR2(8) NOT NULL
 ,schedld_emp_id                NUMBER(3) NOT NULL
 ,schedld_begn_dtm              DATE NOT NULL
 ,schedld_end_dtm               DATE NOT NULL
 ,CONSTRAINT ws_work_ordr_schedl_m_pk PRIMARY KEY(wos_id)
 ,CONSTRAINT ws_work_ordr_schedl_m_uk01 UNIQUE(work_ordr_id, servc_cd)
 ,CONSTRAINT ws_work_ordr_schedl_m_fk01 FOREIGN KEY(work_ordr_id) REFERENCES ws_work_ordr_m(work_ordr_id)
 ,CONSTRAINT ws_work_ordr_schedl_m_fk02 FOREIGN KEY(servc_cd) REFERENCES ws_servc_m(servc_cd)
 ,CONSTRAINT ws_work_ordr_schedl_m_fk03 FOREIGN KEY(work_ordr_id, servc_cd) REFERENCES ws_work_ordr_servc_p(work_ordr_id, servc_cd)
);
CREATE OR REPLACE TRIGGER ws_work_ordr_schedl_m_br
  BEFORE INSERT OR UPDATE OR DELETE
  ON ws_work_ordr_schedl_m
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.wos_id                := ws_wos_id_sq.NEXTVAL;
  ELSIF UPDATING THEN
    NULL;
  ELSIF DELETING THEN
    NULL;
  END IF;
END;
/
CREATE TABLE ws_work_ordr_servc_stts_p
(
  woss_id                       NUMBER(8) NOT NULL
 ,work_ordr_id                  NUMBER(5) NOT NULL
 ,servc_cd                      VARCHAR2(8) NOT NULL
 ,work_ordr_servc_stts_cd       VARCHAR2(8) NOT NULL
 ,CONSTRAINT ws_work_ordr_servc_stts_p_pk PRIMARY KEY(woss_id)
 ,CONSTRAINT ws_work_ordr_servc_stts_p_uk01 UNIQUE(work_ordr_id, servc_cd)
 ,CONSTRAINT ws_work_ordr_servc_stts_p_fk01 FOREIGN KEY(work_ordr_id) REFERENCES ws_work_ordr_m(work_ordr_id)
 ,CONSTRAINT ws_work_ordr_servc_stts_p_fk02 FOREIGN KEY(work_ordr_servc_stts_cd) REFERENCES ws_work_ordr_servc_stts_r(work_ordr_servc_stts_cd)
);
CREATE OR REPLACE TRIGGER ws_work_ordr_servc_stts_p_br
  BEFORE INSERT OR UPDATE OR DELETE
  ON ws_work_ordr_servc_stts_p
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.woss_id               := ws_woss_id_sq.NEXTVAL;
  ELSIF UPDATING THEN
    NULL;
  ELSIF DELETING THEN
    NULL;
  END IF;
END;
/