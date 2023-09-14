import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}});
socket.connect();

const renderComment = (comment) => {
  let email = 'Anonymous';
  if (comment.user) {
    email = comment.user.email;
  };


  return `
    <li class="collection-item">
      ${comment.content}
      <div class="secondary-content">
        ${email}
      </div>
    </li>`;
};

const renderComments = (comments) => {
  return comments.map(elem => { 
    return renderComment(elem);
  });
};

const createSocket = (topicId) => {
  let channel = socket.channel(`comments:${topicId}`, {});
  
  channel
    .join()
    .receive("ok", resp => {
      console.log(resp)
      document.querySelector("#comments-collection").innerHTML = renderComments(resp.comments).join('');
    })
    .receive("error", resp => { console.log("Unable to join", resp) });

  channel.on(`comments:${topicId}:new`, (resp) => {
    document.querySelector("#comments-collection").innerHTML += renderComment(resp.comment);
  });

  document.querySelector("#add-comment-btn").addEventListener("click", () => {
    let input = document.querySelector("#add-comment-input");
    channel.push("comment:add", { content: input.value });
    input.value = "";
  });
};

window.createSocket = createSocket;
