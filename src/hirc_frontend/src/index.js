import { microblog } from "../../declarations/microblog";


async function post() {
  let post_button = document.getElementById("post");
  post_button.disabled = true;
  let error = document.getElementById("error");
  error.innerText = "";
  let textarea = document.getElementById("message");
  let otp = document.getElementById("otp").value;
  let text = textarea.value;
  try {
    await microblog.post(text);
    textarea.value = "";
  } catch (err) {
    console.log(err)
    error.innerText = "Post Failed!";
  }

  post_button.disabled = false;
}
var num_posts = 0;
async function load_posts() {
  let posts_section = document.getElementById("posts");
  let posts = await microblog.posts(0);
  if (num_posts == posts.length) return;
  posts_section.replaceChildren([]);
  num_posts = posts.length;
  for (var i = 0; i < posts.length; i++) {
    let post = document.createElement("p");
    post.innerText = posts[i].text
    posts_section.appendChild(post)
  }
}

var num_follows = 0;
async function load_follows() {
  let follows_section = document.getElementById("followedname");
  let follownames = await microblog.followsname();//[Text]
  let allposts_section = document.getElementById("allposts");
  if (num_follows == follownames.length) return;
  follows_section.replaceChildren([]);
  num_follows = follownames.length;

  for (var i = 0; i < follownames.length; i++) {
    let followname = document.createElement("button");
    followname.innerText = follownames[i];
    followname.onclick = async function () {
      allposts_section.replaceChildren([]);
      let allposts = await microblog.allposts(followname.innerText);
      let clickon = document.createElement("p");
      clickon.innerText = "You clicked on " + followname.innerText + ". His posts as followed : ";
      allposts_section.appendChild(clickon);
      for (var j = 0; j < allposts.length; j++) {
        let allpost = document.createElement("p");
        allpost.innerText = allposts[j].text;
        console.log("innerText: " + allpost.innerText);
        allposts_section.appendChild(allpost);
      };
    };
    follows_section.appendChild(followname);

  }
}


var num_timelines = 0;
async function load_timelines() {
  let timelines_section = document.getElementById("timeline");
  let timeline = await microblog.timeline(0);
  if (num_timelines == timeline.length) return;
  timelines_section.replaceChildren([]);
  num_timelines = timeline.length;
  for (var i = 0; i < timeline.length; i++) {
    let timelineElement = document.createElement("p");
    timelineElement.innerText = " Author: " + timeline[i].author + "\n message: "
      + timeline[i].text + "\n time: " + timeline[i].time;
    timelines_section.appendChild(timelineElement)
  }
}

function load() {
  let post_button = document.getElementById("post");
  post_button.onclick = post;
  load_posts();
  let follow_button = document.getElementById("follow");
  load_follows();
  load_timelines();
}

window.onload = load