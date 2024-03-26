// 30 x 16 squares with 99 mines
// if player chooses square that contains a mine they lose
// if player chooses square that does not contain a mine,
// the number of mines in the neighbouring squares is displayed
// if there are no mines in the neighbouring squares,
// the surrounding squares are revealed, this process is recursive

BlockManager game;
void setup()
{
  //fullScreen();
  size(600, 320);
  game = new BlockManager();
}
void draw()
{
  game.update();
}
class Block
{
  PVector pos;            // position of block is top left corner
  boolean isMine;         // if block contains a mine 
  int surMines;           // number of mines surrounding block
  float bWidth, bHeight;
  //boolean isMarked;       // player suspects block contains a mine
  //boolean isUncovered;    // the player has already uncovered the block
  int blockState;         // (hover = 0, covered = 1, uncovered = 2, marked = 3)
  Block(float x, float y, float bWidth_, float bHeight_)
  {
    pos = new PVector(x, y);
    bWidth = bWidth_;
    bHeight = bHeight_;
    isMine = false;
    blockState = 1;
  }
  void covered()
  {
    stroke(0);
    fill(100);
    rect(pos.x, pos.y, bWidth, bHeight);
  }
  void scrollOver()
  {
    stroke(0);
    fill(125, 203, 138);
    rect(pos.x, pos.y, bWidth, bHeight);
  }
  void mineReveal()
  {
    stroke(0);
    fill(206, 90, 90);
    rect(pos.x, pos.y, bWidth, bHeight);
    textSize(15);
    textAlign(LEFT, TOP);
    fill(0);
    text('M', pos.x, pos.y);
  }
  void mark()
  {
    stroke(0);
    fill(211, 197, 87);
    rect(pos.x, pos.y, bWidth, bHeight);
    textSize(15);
    textAlign(LEFT, TOP);
    fill(0);
    text("  !", pos.x, pos.y);
  }
  void uncovered()
  {
    stroke(0);
    fill(143 ,145, 240);
    rect(pos.x, pos.y, bWidth, bHeight);
    textSize(15);
    textAlign(LEFT, TOP);
    fill(0);
    text(surMines, pos.x, pos.y);
  }
}
class BlockManager
{
  int numRows, numColumns, numMines, selectRow, selectColumn, numUncovered;
  float bWidth, bHeight;
  Block[][] blockArray;
  boolean struckMine;
  BlockManager()
  {
    numRows = 16;
    numColumns = 30;
    numMines = 50;//99;
    bWidth = width/numColumns;
    bHeight = height/numRows;
    blockArray = new Block[numRows][numColumns];
    struckMine = false;
    
    for(int i = 0; i < numRows; i++)
    {
      for(int j = 0; j < numColumns; j++)
      {
        blockArray[i][j] = new Block(j*bWidth, i*bHeight, bWidth, bHeight);
      }
    }
    
    while(numMines > 0)
    {
      int randRow = int(random(numRows));            // random function chooses number smaller but not equal to parameter
      int randColumn = int(random(numColumns));
      if(!blockArray[randRow][randColumn].isMine)
      {
        blockArray[randRow][randColumn].isMine = true;
        //blockArray[randRow][randColumn].blockState = 4;
        numMines--;
      }
    }
    
    for(int i = 0; i < numRows; i++)
    {
      for(int j = 0; j < numColumns; j++)
      {
        int totalSum = 0;
        for(int y = -1; y < 2; y++)
        {
          for(int x = -1; x < 2; x++)
          {
            if((i + y) >= 0 && (j + x) >= 0 && (i+y) < numRows && (j+x) < numColumns)
            {
              if(blockArray[i+y][j+x].isMine)
              {
                totalSum++;
              }
            }
          }
        }
        blockArray[i][j].surMines = totalSum;
      }
    }
  }
  void update()
  {
    numUncovered = 0;
    selectRow = int(mouseY/bHeight);
    selectColumn = int(mouseX/bWidth);
    if(blockArray[selectRow][selectColumn].blockState == 1)
    {
      blockArray[selectRow][selectColumn].blockState = 0;
    }
    for(int i = 0; i < numRows; i++)
    {
      for(int j = 0; j < numColumns; j++)
      {
        if(struckMine && blockArray[i][j].isMine)
        {
          blockArray[i][j].blockState = 4;
        }
        switch(blockArray[i][j].blockState)
        {
          case 0: blockArray[i][j].scrollOver();
                  blockArray[i][j].blockState = 1;
                  break;
          case 1: blockArray[i][j].covered();
                  break;
          case 2: blockArray[i][j].uncovered();
                  numUncovered++;
                  break;
          case 3: blockArray[i][j].mark();
                  break;
          case 4: blockArray[i][j].mineReveal();
                  break;
          default: blockArray[i][j].covered();
        }
      }
    }
  }
  void recursiveReveal(int r, int c)
  {
    if(r >= 0 && c >= 0 && r < numRows && c < numColumns)
    {
      if(blockArray[r][c].surMines == 0 && blockArray[r][c].blockState != 2)
      {
        blockArray[r][c].blockState = 2;
        
        recursiveReveal(r - 1, c - 1);
        recursiveReveal(r - 1, c);
        recursiveReveal(r - 1, c + 1);
        recursiveReveal(r, c - 1);
        //recursiveReveal(r, c);
        recursiveReveal(r, c + 1);
        recursiveReveal(r + 1, c - 1);
        recursiveReveal(r + 1, c);
        recursiveReveal(r + 1, c + 1);
      }
      else
      {
        blockArray[r][c].blockState = 2;
      }
    }
  }
  void leftClick()
  {
    println("left");
    if(blockArray[selectRow][selectColumn].isMine)
    {
      struckMine = true;
    }
    else
    {
      recursiveReveal(selectRow, selectColumn);
    }
  }
  void rightClick()
  {
    println("right");
    blockArray[selectRow][selectColumn].mark();
    blockArray[selectRow][selectColumn].blockState = 3;
  }
}
void mouseClicked()
{
  if(mouseButton == LEFT)
  {
    game.leftClick();
  }
  else if(mouseButton == RIGHT)
  {
    game.rightClick();  }
}
