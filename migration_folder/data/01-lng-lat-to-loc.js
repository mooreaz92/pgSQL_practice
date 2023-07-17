const express = require('express');
const pg = require('pg');

const pool = new pg.Pool({
  host: 'localhost',
  port: 5432,
  database: 'socialnetwork',
  user: 'postgres',
  password: '[REDACTED]',
});

pool.query(`
  UPDATE posts
  SET loc = POINT(lng, lat)
  WHERE loc IS NULL;
  `)
  .then(() => {
    console.log('Success!');
    pool.end();
  }).catch((err) => console.error(err.message));