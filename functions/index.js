const functions = require("firebase-functions/v2");
const express = require("express");
const cors = require("cors");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

const app = express();
app.use(cors({origin: true}));
app.use(express.json());

/**
 * ✅ Health Check Endpoint
 */
app.get("/health", (req, res) => {
  res.json({status: "healthy", timestamp: new Date().toISOString()});
});

/**
 * ✅ Helper: Get M-Pesa Access Token
 */
async function getAccessToken() {
  const consumerKey = process.env.MPESA_CONSUMER_KEY;
  const consumerSecret = process.env.MPESA_CONSUMER_SECRET;
  const auth = Buffer.from(`${consumerKey}:${consumerSecret}`).toString(
      "base64",
  );

  const response = await axios.get(
      "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials",
      {
        headers: {Authorization: `Basic ${auth}`},
      },
  );

  return response.data.access_token;
}

/**
 * ✅ Initiate STK Push
 */
app.post("/initiate-stk-push", async (req, res) => {
  try {
    const {phone, amount} = req.body;

    if (!phone || !amount) {
      return res
          .status(400)
          .json({error: "Phone number and amount are required"});
    }

    const accessToken = await getAccessToken();
    const shortcode = process.env.MPESA_SHORTCODE;
    const passkey = process.env.MPESA_PASSKEY;
    const callbackUrl = process.env.MPESA_CALLBACK_URL;

    // Generate timestamp
    const timestamp = new Date()
        .toISOString()
        .replace(/[-:TZ.]/g, "")
        .slice(0, 14);

    // Generate password
    const password = Buffer.from(shortcode + passkey + timestamp).toString(
        "base64",
    );

    const payload = {
      BusinessShortCode: shortcode,
      Password: password,
      Timestamp: timestamp,
      TransactionType: "CustomerPayBillOnline",
      Amount: amount,
      PartyA: phone,
      PartyB: shortcode,
      PhoneNumber: phone,
      CallBackURL: callbackUrl,
      AccountReference: "Test123",
      TransactionDesc: "Payment",
    };

    const response = await axios.post(
        "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest",
        payload,
        {
          headers: {Authorization: `Bearer ${accessToken}`},
        },
    );

    res.json(response.data);
  } catch (error) {
    console.error(
        "STK Push Error:",
      error.response && error.response.data ?
        error.response.data :
        error.message,
    );
    res.status(500).json({error: "Failed to initiate STK Push"});
  }
});

/**
 * ✅ M-Pesa Callback URL
 */
app.post("/mpesa-callback", (req, res) => {
  console.log("M-Pesa Callback:", req.body);
  res.json({message: "Callback received successfully"});
});

/**
 * ✅ Firebase Secrets Test
 */
app.get("/test-config", (req, res) => {
  res.json({
    consumerKey: process.env.MPESA_CONSUMER_KEY ? "SET" : "NOT SET",
    consumerSecret: process.env.MPESA_CONSUMER_SECRET ? "SET" : "NOT SET",
    shortcode: process.env.MPESA_SHORTCODE ? "SET" : "NOT SET",
    passkey: process.env.MPESA_PASSKEY ? "SET" : "NOT SET",
    callbackUrl: process.env.MPESA_CALLBACK_URL ? "SET" : "NOT SET",
  });
});

/**
 * ✅ Export Express App to Firebase
 */
exports.api = functions.https.onRequest(app);
