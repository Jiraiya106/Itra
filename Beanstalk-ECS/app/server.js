import express from "express";

const app = express();

const port = process.env.PORT || 3000;

app.listen(port, () => {
    console.info("\x1b[42m", "Express server listening on port " + port, "\x1b[0m");
});