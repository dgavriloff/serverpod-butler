BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "class_session" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "prompt" text NOT NULL,
    "roomCount" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "live_session" (
    "id" bigserial PRIMARY KEY,
    "sessionId" bigint NOT NULL,
    "urlTag" text NOT NULL,
    "isActive" boolean NOT NULL,
    "transcript" text NOT NULL,
    "startedAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "url_tag_active_idx" ON "live_session" USING btree ("urlTag", "isActive");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "room" (
    "id" bigserial PRIMARY KEY,
    "sessionId" bigint NOT NULL,
    "roomNumber" bigint NOT NULL,
    "content" text NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "session_room_unique_idx" ON "room" USING btree ("sessionId", "roomNumber");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "transcript_chunk" (
    "id" bigserial PRIMARY KEY,
    "sessionId" bigint NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "text" text NOT NULL
);

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "live_session"
    ADD CONSTRAINT "live_session_fk_0"
    FOREIGN KEY("sessionId")
    REFERENCES "class_session"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "room"
    ADD CONSTRAINT "room_fk_0"
    FOREIGN KEY("sessionId")
    REFERENCES "class_session"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "transcript_chunk"
    ADD CONSTRAINT "transcript_chunk_fk_0"
    FOREIGN KEY("sessionId")
    REFERENCES "class_session"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR breakout_butler
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('breakout_butler', '20260127023206198', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260127023206198', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260109031533194', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260109031533194', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
