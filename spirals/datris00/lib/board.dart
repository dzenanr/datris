part of datris;

class Board {
  static const num IMAGE_COUNT   = 8;
  static const num BOARD_HEIGHT  = 16; // squares
  static const num BOARD_WIDTH   = 10; // squares
  static const num SQUARE_WIDTH  = 16; // pixels
  static const num SQUARE_HEIGHT = 16; // pixels

  var squareImages = new List<ImageElement>();
  var board = new List<List<num>>();

  Board() {
    for (num count = 0; count < IMAGE_COUNT; count++) {
      ImageElement imgElement = new Element.tag("img");
      imgElement.src = 'images/s${count}.png';
      squareImages.add(imgElement);
    }
    for (num i = 0; i < BOARD_HEIGHT; i++) {
      board.add([]);
      for (num j = 0; j < BOARD_WIDTH; j++) {
        board[i].add(0);
      }
    }
    draw();
  }

  draw() {
    DivElement boardElement = querySelector("#board");
    PreElement preElement = new Element.tag("pre");
    boardElement.nodes.add(preElement);
    preElement.classes.add("board");
    for (num i = 0; i < BOARD_HEIGHT; i++) {
      DivElement divElement = new Element.tag("div");
      preElement.nodes.add(divElement);
      for (num j = 0; j < BOARD_WIDTH; j++) {
        ImageElement img = new Element.tag("img");
        divElement.nodes.add(img);
        img.id = "s-$i-$j";
        img.src = "images/s${board[i][j].abs()}.png";
        img.width = SQUARE_WIDTH;
        img.height = SQUARE_HEIGHT;
      }
      ImageElement rightMargin = new Element.tag("img");
      divElement.nodes.add(rightMargin);
      rightMargin.src = "images/g.png";
      rightMargin.width = 1;
      rightMargin.height = SQUARE_HEIGHT;
    }
    DivElement trailingElement = new Element.tag("div");
    preElement.nodes.add(trailingElement);
    ImageElement trailingImg = new Element.tag("img");
    trailingElement.nodes.add(trailingImg);
    trailingImg.src = "images/g.png";
    trailingImg.id = "board-trailing-img";
    trailingImg.width = BOARD_WIDTH * 16 + 1;
    trailingImg.height = 1;
  }
}

