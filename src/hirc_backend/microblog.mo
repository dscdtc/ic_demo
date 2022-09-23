import D "mo:base/Debug";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Time "mo:base/Time";

actor {
    var lastTime = Time.now();
    public func greet(name : Text) : async Text {
       let now = Time.now();
       let elapsedSeconds = (now - lastTime) / 1000_000_000;
       lastTime := now;
       
       
       return "Hello, " # name # "!" #
         " I was last called " # Int.toText(elapsedSeconds) # " seconds ago";
    
    };
    public type Message = 
    {
        text : Text;
        time : Time.Time;
        author : ?Text;
    };
    
    public type Microblog = actor {
        set_name:shared(Text) -> async ();
        get_name:shared() -> async ?Text;
        follow: shared (Principal) -> async ();//关注新用户
        follows: shared query () -> async [Principal];//return followers list
        followsname: shared query () -> async [?Text];//return followers list nickname
        post: shared (Text) -> async ();//post new message 
        posts: shared query (Time.Time) -> async [Message];//return all message published
        timeline : shared (Time.Time) -> async [Message]; //return all meassage published by all followers
        allposts : shared (Text) -> async [Message]; //return all meassage published by specific follower
        unpost :shared ()-> async ();
    };
    
    stable var name :?Text = null;

    public func set_name(author:Text) : async (){
        name := ?author;
    };

    public func get_name() : async ?Text{
        name
    };


    stable var followed : List.List<Principal> = List.nil(); //the list of people you followed (Principal)
    stable var followedname : List.List<?Text> = List.nil(); //the list of people you followed (Text nickname)

    public shared func follow(id: Principal) : async (){
        let canister:Microblog = actor (Principal.toText(id));           
        
        let nickname = await canister.get_name();
        followedname := List.push(nickname, followedname);
    
        followed := List.push(id, followed);
        };

    public shared query func follows() : async [Principal] {
        List.toArray(followed)
    };

    public shared query func followsname() : async [?Text] {
        List.toArray(followedname)
    };

    stable var messages : List.List<Message> =List.nil();

    
    public shared (message) func post(text: Text) : async (){
        //assert (Principal.toText(msg.caller)== "6fe5r-75tlg-i4t4q-zzr2y-hvi3m-jj76y-nqzti-xutid-3uttm-ldxv6-aae");
        var now = Time.now();
        let canister:Microblog = actor(Principal.toText(message.caller));
        let name = await canister.get_name();
        var msg = {text=text;time=now;author= name;};
        messages := List.push(msg, messages)
    };

    public shared (message) func unpost() : async (){
        let (poped, newmessages) = List.pop<Message>(messages);
        messages := newmessages;
    };

    public shared query func posts (since: Time.Time) : async [Message]{
        
        var newmessages : List.List<Message> =List.nil();
        for (msg in Iter.fromArray(List.toArray(messages))){
            if(Int.greater(msg.time,since)){
                newmessages := List.push(msg,newmessages);
            };
        };
        List.toArray(newmessages)
    };
    
    public shared func timeline(since: Time.Time) : async [Message]{
        //create a empty list to store message
        var all : List.List<Message> = List.nil();
        for (id in Iter.fromList(followed)){
            let canister:Microblog = actor (Principal.toText(id));           
            let msgs = await canister.posts(since);
           for (msg in Iter.fromArray(msgs)){
               all := List.push(msg, all);           
           }
        };
        List.toArray(all)
    };
    //input:nickname 
    public shared func allposts(nickname:Text) : async [Message]{
        //create a empty list to store message
        var all : List.List<Message> = List.nil();
        
        for (id in Iter.fromList(followed)){
            let canister:Microblog = actor (Principal.toText(id)); 
            var optionname = (await canister.get_name());
            var name = Option.unwrap(optionname);
            if (name == nickname){
                let msgs = await canister.posts(0);
                for (msg in Iter.fromArray(msgs)){
                    all := List.push(msg, all);           
                }
            }; 
                     
        };
        List.toArray(all);
    };
};