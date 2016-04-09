import tweepy

consumer_key = "EhfyLQIFWVbGfz3bmn1a9c9td";
#eg: consumer_key = "YisfFjiodKtojtUvW4MSEcPm";


consumer_secret = "NvqXkGjxwIaocJaIgllKt8I9SrvOhqYWwEewYlTrgAj0ggxrbQ";
#eg: consumer_secret = "YisfFjiodKtojtUvW4MSEcPmYisfFjiodKtojtUvW4MSEcPmYisfFjiodKtojtUvW4MSEcPm";

access_token = "14988646-7wgi1V2NjXNOp6bJU6A0fpcJaNri1puJclGGc4r3E";
#eg: access_token = "YisfFjiodKtojtUvW4MSEcPmYisfFjiodKtojtUvW4MSEcPmYisfFjiodKtojtUvW4MSEcPm";

access_token_secret = "E0aGfrYzfft7u6bjOSxjBRRz4McJTSzlGattuRPCY5gRd";
#eg: access_token_secret = "YisfFjiodKtojtUvW4MSEcPmYisfFjiodKtojtUvW4MSEcPmYisfFjiodKtojtUvW4MSEcPm";


auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

api = tweepy.API(auth)



