const express = require("express");
const sql = require("mssql");

const express = require("express");
const path = require("path");
const app = express();
const port = process.env.PORT || 3000;

// Use a single environment variable for DB connection
const dbConnectionString = process.env.DB_CONNECTION_STRING;

if (!dbConnectionString) {
  console.error("ERROR: DB_CONNECTION_STRING environment variable not set!");
  process.exit(1);
}

// Serve static files from "public"
app.use(express.static(path.join(__dirname, "public")));

app.get("/products", async (req, res) => {
  try {
    // Connect to the database
    await sql.connect(dbConnectionString);

    // Query the Products table
    const result = await sql.query`SELECT * FROM Products`;

    // Return results as JSON
    res.json(result.recordset);
  } catch (err) {
    console.error("SQL Error:", err);
    res.status(500).json({ error: err.message });
  }
});

app.listen(port, () => console.log(`API listening on port ${port}`));
