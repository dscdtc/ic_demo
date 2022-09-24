import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Time "mo:base/Time";

actor {
  public type Message = {
    text : Text;
    time : Time.Time;
    author:?Text;
  };

  public type Microblog = actor{
    follow:shared(Principal) -> async();
    follows:shared query () -> async[Principal];
    follows_name:shared query () -> async[?Text];
    post:shared (Text,Text) -> async();
    posts:shared query (Time.Time) -> async [Message];
    timeline:shared (Time.Time) -> async [Message];
    set_name:shared (Text) -> async();
    get_name:shared () -> async ?Text;
  };
  
  var followed :List.List<Principal> = List.nil();
  var followed_name :List.List<?Text> = List.nil();
  stable var author_name : ?Text = ?"admin";

  public shared func set_name(name: ?Text) {
    author_name := name;
  };

  public shared func get_name() : async ?Text {
    author_name
  };

  public shared func follow(id:Principal):async(){
    followed := List.push(id,followed);
    let canister : Microblog = actor(Principal.toText(id));
    let follow_name = await canister.get_name();
    followed_name := List.push(follow_name,followed_name)
  };

  public shared query func follows():async[Principal]{
    List.toArray(followed)
  };

  public shared query func follows_name():async[?Text]{
    List.toArray(followed_name)
  };

  var message:List.List<Message> = List.nil();

  public shared func post(otp:Text,text:Text):async(){
    assert(otp=="888888");
    let now : Int = Time.now();
    let msg : Message = {
      text = text;
      time = now;
      author = author_name;
    };
    message := List.push(msg,message)
  };

  public shared query func posts(since: Time.Time):async[Message]{
    var pick_message:List.List<Message> = List.nil();
    for (msg in Iter.fromList(message)){
      if (msg.time > since){
        pick_message:=List.push(msg,pick_message)
      }
    };
    List.toArray(pick_message)
  };

  public shared func timeline(since: Time.Time):async[Message]{
    var pick_message : List.List<Message> = List.nil();
    for (id in Iter.fromList(followed)){
      let canister : Microblog = actor(Principal.toText(id));
      let msgs = await canister.posts(since);
      for (msg in Iter.fromArray(msgs)){
        if (msg.time > since){
          pick_message:=List.push(msg,pick_message)
        }
      };
    };
    List.toArray(pick_message)
  };
};