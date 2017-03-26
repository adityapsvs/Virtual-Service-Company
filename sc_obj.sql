DROP TABLE sc_cust_service_link;
DROP TABLE sc_cust_mst;
DROP TABLE sc_emp_service_link;
DROP TABLE sc_emp_job_link;
DROP TABLE sc_emp_mst;
DROP TABLE sc_service_mst;
DROP TABLE sc_job_mst;
DROP TABLE sc_persn_phone_link;
DROP TABLE sc_persn_email_link;
DROP TABLE sc_persn_phys_addr_link;
DROP TABLE sc_phone_mst;
DROP TABLE sc_email_addr_mst;
DROP TABLE sc_phys_addr_mst;
DROP TABLE sc_persn_mst;
DROP SEQUENCE sc_cust_service_link_id_seq;
DROP SEQUENCE sc_cust_id_seq;
DROP SEQUENCE sc_emp_service_link_id_seq;
DROP SEQUENCE sc_emp_job_link_id_seq;
DROP SEQUENCE sc_emp_id_seq;
DROP SEQUENCE sc_service_id_seq;
DROP SEQUENCE sc_job_id_seq;
DROP SEQUENCE sc_persn_phone_link_id_seq;
DROP SEQUENCE sc_persn_email_link_id_seq;
DROP SEQUENCE sc_persn_phys_addr_link_id_seq;
DROP SEQUENCE sc_phone_id_seq;
DROP SEQUENCE sc_email_addr_id_seq;
DROP SEQUENCE sc_phys_addr_id_seq;
DROP SEQUENCE sc_persn_id_seq;


CREATE SEQUENCE sc_persn_id_seq;
CREATE TABLE sc_persn_mst
(
  persn_id                      NUMBER(5) PRIMARY KEY
 ,persn_nm                      VARCHAR2(32) NOT NULL
 ,persn_birth_dt                DATE
);
CREATE TRIGGER sc_pern_mst_bir
  BEFORE INSERT
  ON sc_persn_mst
  FOR EACH ROW
BEGIN
  :new.persn_id              := sc_persn_id_seq.NEXTVAL;
END;
/
CREATE SEQUENCE sc_phys_addr_id_seq;
CREATE TABLE sc_phys_addr_mst
(
  phys_addr_id                  NUMBER(5) PRIMARY KEY
 ,addr_line_1                   VARCHAR2(32) NOT NULL
 ,addr_line_2                   VARCHAR2(32)
 ,city_nm                       VARCHAR2(32) NOT NULL
 ,state_cd                      VARCHAR2(2) NOT NULL
 ,postal_cd                     VARCHAR2(6) NOT NULL
);
CREATE TRIGGER sc_phys_addr_mst_bir
  BEFORE INSERT
  ON sc_phys_addr_mst
  FOR EACH ROW
BEGIN
  :new.phys_addr_id          := sc_phys_addr_id_seq.NEXTVAL;
END;
/
CREATE SEQUENCE sc_email_addr_id_seq;
CREATE TABLE sc_email_addr_mst
(
  email_addr_id                 NUMBER(5) PRIMARY KEY
 ,email_addr                    VARCHAR2(32) NOT NULL UNIQUE
);
CREATE TRIGGER sc_email_addr_mst_bir
  BEFORE INSERT
  ON sc_email_addr_mst
  FOR EACH ROW
BEGIN
  :new.email_addr_id         := sc_email_addr_id_seq.NEXTVAL;
END;
/
CREATE SEQUENCE sc_phone_id_seq;
CREATE TABLE sc_phone_mst
(
  phone_id                      NUMBER(5) PRIMARY KEY
 ,phone_nbr                     VARCHAR2(10) NOT NULL UNIQUE
);
CREATE TRIGGER sc_phone_mst_bir
  BEFORE INSERT
  ON sc_phone_mst
  FOR EACH ROW
BEGIN
  :new.phone_id              := sc_phone_id_seq.NEXTVAL;
END;
/
CREATE SEQUENCE sc_persn_phys_addr_link_id_seq;
CREATE TABLE sc_persn_phys_addr_link
(
  persn_phys_addr_link_id       NUMBER(5) PRIMARY KEY
 ,persn_id                      NUMBER(5) NOT NULL   REFERENCES sc_persn_mst(persn_id)
 ,phys_addr_id                  NUMBER(5) NOT NULL   REFERENCES sc_phys_addr_mst(phys_addr_id)
 ,priority_seq_nbr              NUMBER(2)
 ,start_dt                      DATE NOT NULL
 ,end_dt                        DATE
);
CREATE TRIGGER sc_persn_phys_addr_link_bir
  BEFORE INSERT
  ON sc_persn_phys_addr_link
  FOR EACH ROW
BEGIN
  :new.persn_phys_addr_link_id := sc_persn_phys_addr_link_id_seq.NEXTVAL;
END;
/
CREATE SEQUENCE sc_persn_email_link_id_seq;
CREATE TABLE sc_persn_email_link
(
  persn_email_link_id           NUMBER(5) PRIMARY KEY
 ,persn_id                      NUMBER(5) NOT NULL   REFERENCES sc_persn_mst(persn_id)
 ,email_addr_id                 NUMBER(5) NOT NULL   REFERENCES sc_email_addr_mst(email_addr_id)
 ,priority_seq_nbr              NUMBER(2)
 ,start_dt                      DATE NOT NULL
 ,end_dt                        DATE
);
CREATE TRIGGER sc_persn_email_link_bir
  BEFORE INSERT
  ON sc_persn_email_link
  FOR EACH ROW
BEGIN
  :new.persn_email_link_id   := sc_persn_email_link_id_seq.NEXTVAL;
END;
/
CREATE SEQUENCE sc_persn_phone_link_id_seq;
CREATE TABLE sc_persn_phone_link
(
  persn_phone_link_id           NUMBER(5) PRIMARY KEY
 ,persn_id                      NUMBER(5) NOT NULL   REFERENCES sc_persn_mst(persn_id)
 ,phone_id                      NUMBER(5) NOT NULL   REFERENCES sc_phone_mst(phone_id)
 ,texting_enabled_yn            VARCHAR2(1) NOT NULL CHECK(texting_enabled_yn IN ('Y', 'N'))
 ,priority_seq_nbr              NUMBER(2)
 ,start_dt                      DATE NOT NULL
 ,end_dt                        DATE
);
CREATE TRIGGER sc_persn_phone_link_bir
  BEFORE INSERT
  ON sc_persn_phone_link
  FOR EACH ROW
BEGIN
  :new.persn_phone_link_id   := sc_persn_phone_link_id_seq.NEXTVAL;
END;
/
CREATE SEQUENCE sc_job_id_seq;
CREATE TABLE sc_job_mst
(
  job_id                        NUMBER(5) PRIMARY KEY
 ,job_nm                        VARCHAR(32) NOT NULL UNIQUE
);
CREATE TRIGGER sc_job_mst_bir
  BEFORE INSERT
  ON sc_job_mst
  FOR EACH ROW
BEGIN
  :new.job_id                := sc_job_id_seq.NEXTVAL;
END;
/
CREATE SEQUENCE sc_service_id_seq;
CREATE TABLE sc_service_mst
(
  service_id                    NUMBER(5) PRIMARY KEY
 ,service_nm                    VARCHAR2(32) NOT NULL UNIQUE
 ,chg_amt                       NUMBER(7, 2)
);
CREATE TRIGGER sc_service_mst_bir
  BEFORE INSERT
  ON sc_service_mst
  FOR EACH ROW
BEGIN
  :new.service_id            := sc_service_id_seq.NEXTVAL;
END;
/
CREATE SEQUENCE sc_emp_id_seq;
CREATE TABLE sc_emp_mst
(
  emp_id                        NUMBER(5) PRIMARY KEY
 ,persn_id                      NUMBER(5) NOT NULL   REFERENCES sc_persn_mst(persn_id)
);
CREATE TRIGGER sc_emp_mst_bir
  BEFORE INSERT
  ON sc_emp_mst
  FOR EACH ROW
BEGIN
  :new.emp_id                := sc_emp_id_seq.NEXTVAL;
END;
/
CREATE SEQUENCE sc_emp_job_link_id_seq;
CREATE TABLE sc_emp_job_link
(
  emp_job_link_id               NUMBER(5) PRIMARY KEY
 ,emp_id                        NUMBER(5) NOT NULL   REFERENCES sc_emp_mst(emp_id)
 ,job_id                        NUMBER(5) NOT NULL   REFERENCES sc_job_mst(job_id)
 ,start_dt                      DATE NOT NULL
 ,end_dt                        DATE
);
CREATE TRIGGER sc_emp_job_link_bir
  BEFORE INSERT
  ON sc_emp_job_link
  FOR EACH ROW
BEGIN
  :new.emp_job_link_id       := sc_emp_job_link_id_seq.NEXTVAL;
END;
/
CREATE SEQUENCE sc_emp_service_link_id_seq;
CREATE TABLE sc_emp_service_link
(
  emp_service_link_id           NUMBER(5) PRIMARY KEY
 ,emp_id                        NUMBER(5) NOT NULL   REFERENCES sc_emp_mst(emp_id)
 ,service_id                    NUMBER(5) NOT NULL   REFERENCES sc_service_mst(service_id)
 ,start_dt                      DATE NOT NULL
 ,end_dt                        DATE
);
CREATE TRIGGER sc_emp_service_link_bir
  BEFORE INSERT
  ON sc_emp_service_link
  FOR EACH ROW
BEGIN
  :new.emp_service_link_id   := sc_emp_service_link_id_seq.NEXTVAL;
END;
/
CREATE SEQUENCE sc_cust_id_seq;
CREATE TABLE sc_cust_mst
(
  cust_id                       NUMBER(5) PRIMARY KEY
 ,persn_id                      NUMBER(5) NOT NULL   REFERENCES sc_persn_mst(persn_id)
 ,start_dt                      DATE NOT NULL
);
CREATE TRIGGER sc_cust_mst_bir
  BEFORE INSERT
  ON sc_cust_mst
  FOR EACH ROW
BEGIN
  :new.cust_id               := sc_cust_id_seq.NEXTVAL;
END;
/
CREATE SEQUENCE sc_cust_service_link_id_seq;
CREATE TABLE sc_cust_service_link
(
  cust_service_link_id          NUMBER(5) PRIMARY KEY
 ,cust_id                       NUMBER(5) NOT NULL   REFERENCES sc_cust_mst(cust_id)
 ,requested_sevice_id           NUMBER(5) NOT NULL   REFERENCES sc_service_mst(service_id)
 ,requested_dtm                 DATE NOT NULL
 ,assigned_emp_id               NUMBER(5)   REFERENCES sc_emp_mst(emp_id)
 ,service_start_dtm             DATE
 ,service_end_dtm               DATE
 ,total_chg_amt                 NUMBER(7, 2)
 ,paid_dtm                      DATE
 ,total_paid_amt                NUMBER(7, 2)
);
CREATE TRIGGER sc_cust_service_link_bir
  BEFORE INSERT
  ON sc_cust_service_link
  FOR EACH ROW
BEGIN
  :new.cust_service_link_id  := sc_cust_service_link_id_seq.NEXTVAL;
END;
/
