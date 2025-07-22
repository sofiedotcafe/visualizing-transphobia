-- schema.sql
-- To read this schema into the database, run: sqlite3 network.sqlite3 < schema.sql

-- Enables foreign key constraints.
PRAGMA foreign_keys=ON;

-- Table to store allowed entity types (like enum)
CREATE TABLE __meta_entity_types (
    type TEXT PRIMARY KEY
);

-- Insert predefined entity types
INSERT INTO __meta_entity_types (type) VALUES 
  ('person'),
  ('group'),
  ('defunct'),
  ('pseudoscientific theory');

-- Main table for entities with UUID-style TEXT IDs
CREATE TABLE entities (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    FOREIGN KEY (type) REFERENCES __meta_entity_types (type),
    UNIQUE (name, type)
);

-- Table to store connections between entities (directed edges)
CREATE TABLE connections (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    from_id TEXT NOT NULL,
    to_id TEXT NOT NULL,
    FOREIGN KEY (from_id) REFERENCES entities (id),
    FOREIGN KEY (to_id) REFERENCES entities (id),
    UNIQUE (from_id, to_id)
);

-- A view for abstracted human-readable connections
CREATE VIEW connections_abstraction AS
SELECT
    c.id,
    e1.name AS from_name,
    e1.type AS from_type,
    e2.name AS to_name,
    e2.type AS to_type
FROM connections c
JOIN entities e1 ON c.from_id = e1.id
JOIN entities e2 ON c.to_id = e2.id;

-- Trigger to handle insertions into the abstracted readable view
CREATE TRIGGER connections_abstraction_insert
INSTEAD OF INSERT ON connections_abstraction
BEGIN
    -- Insert 'from' entity if not already present
    INSERT OR IGNORE INTO entities (name, type)
    VALUES (NEW.from_name, NEW.from_type);

    -- Insert 'to' entity if not already present
    INSERT OR IGNORE INTO entities (name, type)
    VALUES (NEW.to_name, NEW.to_type);

    -- Insert the connection if it does not already exist
    INSERT INTO connections (from_id, to_id)
    SELECT
        (SELECT id FROM entities WHERE name = NEW.from_name AND type = NEW.from_type),
        (SELECT id FROM entities WHERE name = NEW.to_name AND type = NEW.to_type)
    WHERE NOT EXISTS (
        SELECT 1 FROM connections
        WHERE from_id = (SELECT id FROM entities WHERE name = NEW.from_name AND type = NEW.from_type)
          AND to_id = (SELECT id FROM entities WHERE name = NEW.to_name AND type = NEW.to_type)
    );
END;

-- Trigger to handle updates to the abstracted readable view
CREATE TRIGGER connections_abstraction_update
INSTEAD OF UPDATE ON connections_abstraction
BEGIN
    -- Ensure both new entities exist
    INSERT OR IGNORE INTO entities (name, type) VALUES (NEW.from_name, NEW.from_type);
    INSERT OR IGNORE INTO entities (name, type) VALUES (NEW.to_name, NEW.to_type);

    -- Delete the old connection
    DELETE FROM connections
    WHERE id = OLD.id;

    -- Insert the new connection if it doesn't already exist
    INSERT INTO connections (from_id, to_id)
    SELECT
        (SELECT id FROM entities WHERE name = NEW.from_name AND type = NEW.from_type),
        (SELECT id FROM entities WHERE name = NEW.to_name AND type = NEW.to_type)
    WHERE NOT EXISTS (
        SELECT 1 FROM connections
        WHERE from_id = (SELECT id FROM entities WHERE name = NEW.from_name AND type = NEW.from_type)
          AND to_id = (SELECT id FROM entities WHERE name = NEW.to_name AND type = NEW.to_type)
    );
END;

-- Trigger to handle deletions from the abstracted readable view
CREATE TRIGGER connections_abstraction_delete
INSTEAD OF DELETE ON connections_abstraction
BEGIN
    DELETE FROM connections
    WHERE id = OLD.id;
END;
