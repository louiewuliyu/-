public class post

class post {
  int postId;
  int posterId;
  String posterName;
  String postTitle;
  String postArticle;
  int browseNum;
  LinkedList<postcomment> comment;
  Date updateTime;

  class postcomment{
    int replieId;
    int replierId;
    String replierName;
    String subComment;
    Date replieTime;
  }

  public post() {

  }
}
