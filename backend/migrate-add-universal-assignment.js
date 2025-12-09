const Database = require('better-sqlite3');
const path = require('path');

const db = new Database(path.join(__dirname, 'purchase_requisition.db'));

console.log('🔄 Starting universal assignment migration...\n');

try {
    // Check if columns already exist
    const tableInfo = db.prepare('PRAGMA table_info(requisitions)').all();
    const hasAssignedTo = tableInfo.some(col => col.name === 'assigned_to');
    const hasAssignedRole = tableInfo.some(col => col.name === 'assigned_role');

    if (hasAssignedTo && hasAssignedRole) {
        console.log('✅ Columns already exist - skipping migration');
        db.close();
        process.exit(0);
    }

    // Add assigned_to column if it doesn't exist
    if (!hasAssignedTo) {
        console.log('📝 Adding assigned_to column...');
        db.prepare('ALTER TABLE requisitions ADD COLUMN assigned_to INTEGER').run();
        console.log('✅ assigned_to column added');
    }

    // Add assigned_role column if it doesn't exist
    if (!hasAssignedRole) {
        console.log('📝 Adding assigned_role column...');
        db.prepare('ALTER TABLE requisitions ADD COLUMN assigned_role TEXT').run();
        console.log('✅ assigned_role column added');
    }

    // Migrate existing assigned_hod_id data
    console.log('\n📝 Migrating existing assigned_hod_id data...');
    const result = db.prepare(`
        UPDATE requisitions
        SET assigned_to = assigned_hod_id,
            assigned_role = 'hod'
        WHERE assigned_hod_id IS NOT NULL
    `).run();
    console.log(`✅ Migrated ${result.changes} requisitions with assigned HODs`);

    // Create index for better query performance
    console.log('\n📝 Creating index on assigned_to...');
    try {
        db.prepare('CREATE INDEX IF NOT EXISTS idx_requisitions_assigned_to ON requisitions(assigned_to)').run();
        console.log('✅ Index created');
    } catch (err) {
        if (err.message.includes('already exists')) {
            console.log('✅ Index already exists');
        } else {
            throw err;
        }
    }

    console.log('\n✅ Migration completed successfully!');
    console.log('\n📊 Current schema:');
    const updatedInfo = db.prepare('PRAGMA table_info(requisitions)').all();
    const relevantCols = updatedInfo.filter(col =>
        col.name.includes('assigned') || col.name === 'status'
    );
    relevantCols.forEach(col => {
        console.log(`   - ${col.name}: ${col.type}`);
    });

    db.close();
    console.log('\n🎉 All done!');

} catch (error) {
    console.error('❌ Migration failed:', error.message);
    db.close();
    process.exit(1);
}
