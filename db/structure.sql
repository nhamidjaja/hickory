--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE admins (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: featured_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE featured_users (
    user_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    priority integer DEFAULT 9 NOT NULL
);


--
-- Name: feeders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE feeders (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    feed_url character varying NOT NULL,
    title character varying,
    description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    priority integer DEFAULT 9 NOT NULL,
    icon_url character varying
);


--
-- Name: feeders_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE feeders_users (
    feeder_id uuid,
    user_id uuid
);


--
-- Name: gcms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE gcms (
    user_id uuid,
    registration_token character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: open_stories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE open_stories (
    id uuid NOT NULL,
    faver_id uuid NOT NULL,
    content_url character varying NOT NULL,
    title character varying,
    image_url character varying,
    published_at timestamp without time zone,
    faved_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: top_articles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE top_articles (
    content_url character varying NOT NULL,
    feeder_id uuid NOT NULL,
    title character varying,
    image_url character varying,
    published_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    username character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    provider character varying,
    uid character varying,
    omniauth_token character varying,
    authentication_token character varying,
    description text,
    full_name character varying,
    tsv tsvector,
    profile_picture_url character varying,
    open_stories boolean DEFAULT false NOT NULL,
    admin_managed boolean DEFAULT false NOT NULL
);


--
-- Name: admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: featured_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY featured_users
    ADD CONSTRAINT featured_users_pkey PRIMARY KEY (user_id);


--
-- Name: feeders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY feeders
    ADD CONSTRAINT feeders_pkey PRIMARY KEY (id);


--
-- Name: gcms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY gcms
    ADD CONSTRAINT gcms_pkey PRIMARY KEY (registration_token);


--
-- Name: open_stories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY open_stories
    ADD CONSTRAINT open_stories_pkey PRIMARY KEY (id);


--
-- Name: top_articles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY top_articles
    ADD CONSTRAINT top_articles_pkey PRIMARY KEY (content_url);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_admins_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admins_on_email ON admins USING btree (email);


--
-- Name: index_admins_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admins_on_reset_password_token ON admins USING btree (reset_password_token);


--
-- Name: index_feeders_on_feed_url; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_feeders_on_feed_url ON feeders USING btree (feed_url);


--
-- Name: index_feeders_on_priority; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_feeders_on_priority ON feeders USING btree (priority);


--
-- Name: index_feeders_users_on_feeder_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_feeders_users_on_feeder_id ON feeders_users USING btree (feeder_id);


--
-- Name: index_feeders_users_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_feeders_users_on_user_id ON feeders_users USING btree (user_id);


--
-- Name: index_gcms_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_gcms_on_user_id ON gcms USING btree (user_id);


--
-- Name: index_open_stories_on_faved_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_open_stories_on_faved_at ON open_stories USING btree (faved_at DESC);


--
-- Name: index_top_articles_on_published_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_top_articles_on_published_at ON top_articles USING btree (published_at DESC);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_provider_and_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_provider_and_uid ON users USING btree (provider, uid);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_tsv; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_tsv ON users USING gist (tsv);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tsv', 'pg_catalog.simple', 'username', 'full_name');


--
-- Name: fk_rails_1f59cbacad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY top_articles
    ADD CONSTRAINT fk_rails_1f59cbacad FOREIGN KEY (feeder_id) REFERENCES feeders(id);


--
-- Name: fk_rails_a69f82cb31; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY feeders_users
    ADD CONSTRAINT fk_rails_a69f82cb31 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_ffc924a487; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY featured_users
    ADD CONSTRAINT fk_rails_ffc924a487 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20150417100420');

INSERT INTO schema_migrations (version) VALUES ('20150505064648');

INSERT INTO schema_migrations (version) VALUES ('20150617053325');

INSERT INTO schema_migrations (version) VALUES ('20150619110057');

INSERT INTO schema_migrations (version) VALUES ('20150707082554');

INSERT INTO schema_migrations (version) VALUES ('20150707083008');

INSERT INTO schema_migrations (version) VALUES ('20150711044916');

INSERT INTO schema_migrations (version) VALUES ('20150712052148');

INSERT INTO schema_migrations (version) VALUES ('20150712054400');

INSERT INTO schema_migrations (version) VALUES ('20150713102900');

INSERT INTO schema_migrations (version) VALUES ('20150720120110');

INSERT INTO schema_migrations (version) VALUES ('20150804064421');

INSERT INTO schema_migrations (version) VALUES ('20150804064601');

INSERT INTO schema_migrations (version) VALUES ('20150926084547');

INSERT INTO schema_migrations (version) VALUES ('20151125082134');

INSERT INTO schema_migrations (version) VALUES ('20151125164633');

INSERT INTO schema_migrations (version) VALUES ('20160419103453');

INSERT INTO schema_migrations (version) VALUES ('20160520091804');

INSERT INTO schema_migrations (version) VALUES ('20160603075206');

INSERT INTO schema_migrations (version) VALUES ('20160603143833');

INSERT INTO schema_migrations (version) VALUES ('20160608102216');

INSERT INTO schema_migrations (version) VALUES ('20160613034908');

INSERT INTO schema_migrations (version) VALUES ('20160629063913');

INSERT INTO schema_migrations (version) VALUES ('20160630054222');

INSERT INTO schema_migrations (version) VALUES ('20160630061724');

INSERT INTO schema_migrations (version) VALUES ('20160923062536');

INSERT INTO schema_migrations (version) VALUES ('20160924084940');

INSERT INTO schema_migrations (version) VALUES ('20160925073449');

