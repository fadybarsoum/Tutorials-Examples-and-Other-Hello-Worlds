import g4p_controls.*;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.entity.StringEntity;
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;

HttpClient client = new DefaultHttpClient();

String base_url = "https://api.stockfighter.io/ob/api";
String apikey = "3d48b1552ff058f18276a3a5d832bd2334fb71c0"; // my Stockfighter.io permanent API key (should I not make this public?)

String venue = "WELBEX"; // the stock exchange (think NYSE, NASDAQ, etc.)
String stock = "ARMI"; // the actual stock (GOOG, etc.)
String formed_url = String.format("%s/venues/%s/stocks/%s/",base_url, venue, stock);

String account = "SRB2315924"; // the account for this level

int maxBuyingPrice = 4355;

void setup(){
  size(480,320);
  frameRate(30);
  createGUI();
  stroke(0);
}

void draw() {
  background(255);
  if (frameCount%60 == 0){
    int ask = getQuote();
    println("Ask: " + ask);
    println("Max: " + maxBuyingPrice);
    if (ask!= -1 && ask < maxBuyingPrice){
      println("Buying!");
      int bid = maxBuyingPrice;
      order250(bid);
    }
  }
}

// Stackoverflow answer by Pavel Repin
// http://stackoverflow.com/questions/309424/read-convert-an-inputstream-to-a-string
// Accessed 27AUG16 3:06AM (I need to sleep...)
static String streamToString(java.io.InputStream is) {
    java.util.Scanner s = new java.util.Scanner(is).useDelimiter("\\A");
    return s.hasNext() ? s.next() : "";
}

int getQuote(){
  try {
    HttpGet get = new HttpGet(formed_url + "quote/");
    HttpResponse response = client.execute(get);
    JSONObject quote = JSONObject.parse(streamToString(response.getEntity().getContent()));
    if (!quote.isNull("ask"))
      return quote.getInt("ask");
    else
      println(quote);
  } catch (Exception e) {
    e.printStackTrace();
  }
  return -1;
}

void order250(int bid){
  JSONObject postContents = new JSONObject();
  postContents.setString("account", account);
  //postContents.setString("venue", venue);
  //postContents.setString("symbol", stock);
  postContents.setInt("price", bid);
  postContents.setInt("qty", 250);
  postContents.setString("direction", "buy");
  postContents.setString("orderType", "limit");

  try{
    HttpEntity contents = new StringEntity(postContents.toString());
    
    
    HttpPost post = new HttpPost(formed_url + "orders");
    post.setHeader("X-Starfighter-Authorization", apikey);
    post.setEntity(contents);
    HttpResponse response = client.execute(post);
    JSONObject bidresponse = JSONObject.parse(streamToString(response.getEntity().getContent()));
    println("Bid at " + bid);
    println(bidresponse);
  }
  catch(Exception e){
    e.printStackTrace();
  }
}