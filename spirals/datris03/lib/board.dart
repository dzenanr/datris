part of datris;

class Board {
  static const num IMAGE_COUNT   = 8;
  static const num BOARD_HEIGHT  = 16; // squares
  static const num BOARD_WIDTH   = 10; // squares
  static const num SQUARE_WIDTH  = 16; // pixels
  static const num SQUARE_HEIGHT = 16; // pixels

  static const num PIECE_SQUARE_COUNT = 4;
  static const num PIECE_TYPE_COUNT   = 7;
  static const num SLOWEST_SPEED      = 700;
  static const num LINES_MAX          = 3;

  var squareImages = new List<ImageElement>();
  var board = new List<List<num>>();
  num curPiece;
  num curX = 1;
  num curY = 1;
  List<num> dx;
  List<num> dy;
  List<List<num>> dxBank;
  List<List<num>> dyBank;
  List<num> dxPrime;
  List<num> dyPrime;
  List<num> xToErase;
  List<num> yToErase;

  Timer timer;
  num speed = SLOWEST_SPEED;
  num skyline = BOARD_HEIGHT - 1;
  num completedLinesCount = 0;

  String linesMsg = '$LINES_MAX completed lines to win';
  LabelElement linesMsgLabel = querySelector("#lines-msg");
  LabelElement linesCountLabel = querySelector("#lines-count");

  Board() {
    squareImages = [];
    board = [];
    xToErase = [0, 0, 0, 0];
    yToErase = [0, 0, 0, 0];
    dx = [0, 0, 0, 0];
    dy = [0, 0, 0, 0];
    dxPrime = [0, 0, 0, 0];
    dyPrime = [0, 0, 0, 0];
    dxBank = [[], [0, 1, -1, 0], [0, 1, -1, -1], [0, 1, -1, 1], [0, -1, 1, 0], [0, 1, -1, 0], [0, 1, -1, -2], [0, 1, 1, 0]];
    dyBank = [[], [0, 0, 0, 1], [0, 0, 0, 1], [0, 0, 0, 1], [0, 0, 1, 1], [0, 0, 1, 1], [0, 0, 0, 0], [0, 0, 1, 1]];

    for (num count = 0; count < IMAGE_COUNT; count++) {
      ImageElement img = new Element.tag("img");
      img.src = 'images/s${count}.png';
      squareImages.add(img);
    }
    for (num i = 0; i < BOARD_HEIGHT; i++) {
      board.add([]);
      for (num j = 0; j < BOARD_WIDTH; j++) {
        board[i].add(0);
      }
    }

    InputElement leftButton = querySelector("#left");
    leftButton.onClick.listen((e) => moveLeft());
    InputElement rotateButton = querySelector("#rotate");
    rotateButton.onClick.listen((e) => rotate());
    InputElement rightButton = querySelector("#right");
    rightButton.onClick.listen((e) => moveRight());
    InputElement fallButton = querySelector("#fall");
    fallButton.onClick.listen((e) => fall());
    linesMsgLabel.text = '$linesMsg';
    linesCountLabel.text = 'completed lines: $completedLinesCount';

    draw();
    getPiece();
    drawPiece();
    timer = new Timer.periodic(new Duration(milliseconds: speed), (t) {
      play();
    });
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
        ImageElement imgElement = new Element.tag("img");
        divElement.nodes.add(imgElement);
        imgElement.id = "s-$i-$j";
        imgElement.src = "images/s${board[i][j].abs()}.png";
        imgElement.width = SQUARE_WIDTH;
        imgElement.height = SQUARE_HEIGHT;
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

  play() {
    if (!moveDown()) {
      fillMatrix();
      removeLines();
      if (skyline == 0 || !getPiece()) {
        linesMsgLabel.text = 'you lose';
        timer.cancel();
      }
    }
  }

  bool getPiece() {
    num k;
    curPiece = 1 + new Random().nextInt(PIECE_TYPE_COUNT);
    curX = 5;
    curY = 0;
    for (k = 0; k < PIECE_SQUARE_COUNT; k++) {
      dx[k] = dxBank[curPiece][k];
      dy[k] = dyBank[curPiece][k];
    }
    for (k = 0; k < PIECE_SQUARE_COUNT; k++) {
      dxPrime[k] = dx[k];
      dyPrime[k] = dy[k];
    }
    if (pieceFits(curX, curY)) {
      drawPiece();
      return true;
    }
    return false;
  }

  bool pieceFits(x, y) {
    num k, theX, theY;
    for (k = 0; k < PIECE_SQUARE_COUNT; k++) {
      theX = x + dxPrime[k];
      theY = y + dyPrime[k];
      if (theX < 0 || theX >= BOARD_WIDTH || theY >= BOARD_HEIGHT) {
        return false;
      }
      if (theY > -1 && board[theY][theX] > 0) {
        return false;
      }
    }
    return true;
  }

  drawPiece() {
    num k, x, y;
    for (k = 0; k < PIECE_SQUARE_COUNT; k++) {
      x = curX + dx[k];
      y = curY + dy[k];
      if (0 <= y && y < BOARD_HEIGHT && 0 <= x && x < BOARD_WIDTH && board[y][x] != -curPiece) {
        ImageElement img = querySelector("#s-$y-$x");
        img.src = squareImages[curPiece].src;
        board[y][x] = -curPiece;
      }
      x = xToErase[k];
      y = yToErase[k];
      if (board[y][x] == 0) {
        ImageElement img = querySelector("#s-$y-$x");
        img.src = squareImages[0].src;
      }
    }
  }

  erasePiece() {
    num k, x, y;
    for (k = 0; k < PIECE_SQUARE_COUNT; k++) {
      x = curX + dx[k];
      y = curY + dy[k];
      if (0 <= y && y < BOARD_HEIGHT && 0 <= x && x < BOARD_WIDTH) {
        xToErase[k] = x;
        yToErase[k] = y;
        board[y][x] = 0;
      }
    }
  }

  bool moveDown() {
    num k;
    for (k = 0; k < PIECE_SQUARE_COUNT; k++) {
      dxPrime[k] = dx[k];
      dyPrime[k] = dy[k];
    }
    if (pieceFits(curX, curY + 1)) {
      erasePiece();
      curY++;
      drawPiece();
      return true;
    }
    return false;
  }

  moveLeft() {
    num k;
    for (k = 0; k < PIECE_SQUARE_COUNT; k++) {
      dxPrime[k] = dx[k];
      dyPrime[k] = dy[k];
    }
    if (pieceFits(curX - 1, curY)) {
      erasePiece();
      curX--;
      drawPiece();
    }
  }

  moveRight() {
    num k;
    for (k = 0; k < PIECE_SQUARE_COUNT; k++) {
      dxPrime[k] = dx[k];
      dyPrime[k] = dy[k];
    }
    if (pieceFits(curX + 1, curY)) {
      erasePiece();
      curX++;
      drawPiece();
    }
  }

  rotate() {
    num k;
    for (k = 0; k < PIECE_SQUARE_COUNT; k++) {
      dxPrime[k] = dy[k];
      dyPrime[k] = -dx[k];
    }
    if (pieceFits(curX, curY)) {
      erasePiece();
      for (k = 0; k < PIECE_SQUARE_COUNT; k++) {
        dx[k] = dxPrime[k];
        dy[k] = dyPrime[k];
      }
      drawPiece();
    }
  }

  fall() {
    num k;
    for (k = 0; k < PIECE_SQUARE_COUNT; k++) {
      dxPrime[k] = dx[k];
      dyPrime[k] = dy[k];
    }
    if (!pieceFits(curX, curY + 1)) {
      return;
    }
    erasePiece();
    while (pieceFits(curX, curY + 1)) {
      curY++;
    }
    drawPiece();
  }

  fillMatrix() {
    num k, x, y;
    for (k = 0; k < PIECE_SQUARE_COUNT; k++) {
      x = curX + dx[k];
      y = curY + dy[k];
      if (0 <= y && y < BOARD_HEIGHT && 0 <= x && x < BOARD_WIDTH) {
        board[y][x] = curPiece;
        if (y < skyline) {
          skyline = y;
        }
      }
    }
  }

  removeLines() {
    num i, j, k;
    bool gapFound;
    for (i = 0; i < BOARD_HEIGHT; i++) {
      gapFound = false;
      for (j = 0; j < BOARD_WIDTH; j++) {
        if (board[i][j] == 0) {
          gapFound = true;
          break;
        }
      }
      if (!gapFound) {
        for (k = i; k >= skyline; k--) {
          for (j = 0; j < BOARD_WIDTH; j++) {
            board[k][j] = board[k - 1][j];
            ImageElement img = querySelector("#s-$k-$j");
            img.src = squareImages[board[k][j]].src;
          }
        }
        for (j = 0; j < BOARD_WIDTH; j++) {
          board[0][j] = 0;
          ImageElement img = querySelector("#s-0-$j");
          img.src = squareImages[0].src;
        }
        completedLinesCount++;
        linesCountLabel.text = 'completed lines: $completedLinesCount';
        if (completedLinesCount >= LINES_MAX) {
          linesMsgLabel.text = 'you win';
          timer.cancel();
        }
        skyline++;
      }
    }
  }
}

