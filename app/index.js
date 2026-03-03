const express = require("express");
const sql = require("mssql");

const app = express();
const port = process.env.PORT || 3000;

const configA = process.env.DB_A_CONNECTION;
const configB = process.env.DB_B_CONNECTION;

app.get("/products/:db", async (req, res) => {
  const db = req.params.db === "a" ? configA : configB;
  try {
    await sql.connect(db);
    const result = await sql.query`SELECT * FROM Products`;
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(port, () => console.log(`API listening on ${port}`));
