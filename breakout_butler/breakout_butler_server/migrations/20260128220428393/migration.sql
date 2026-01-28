BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "live_session" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "live_session" (
    "id" bigserial PRIMARY KEY,
    "sessionId" bigint NOT NULL,
    "urlTag" text NOT NULL,
    "isActive" boolean NOT NULL,
    "transcript" text NOT NULL,
    "prompt" text NOT NULL,
    "startedAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone,
    "creatorToken" text
);

-- Indexes
CREATE UNIQUE INDEX "url_tag_active_idx" ON "live_session" USING btree ("urlTag", "isActive");

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
-- MIGRATION VERSION FOR breakout_butler
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('breakout_butler', '20260128220428393', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260128220428393', "timestamp" = now();

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
