-- Replication role and physical slot for the ShopFlow read replica.
-- Local assignment only. The password is the same one named in the Compose file.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'shopflow_replicator') THEN
        CREATE ROLE shopflow_replicator
            WITH REPLICATION LOGIN PASSWORD 'shopflow_replica_local_only';
    END IF;
END
$$;

ALTER ROLE shopflow_replicator
    WITH REPLICATION LOGIN PASSWORD 'shopflow_replica_local_only';

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_replication_slots WHERE slot_name = 'shopflow_replica'
    ) THEN
        PERFORM pg_create_physical_replication_slot('shopflow_replica');
    END IF;
END
$$;
