#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdlib.h>

typedef struct {
  int code;
  int value;
} Instruction;

typedef struct {
  int x;
  int y;
  int counter;
  int pos;
  Instruction *instructions;
} State;

void extract_op(char *line, char op[5], size_t len) {
  if (len < 5) {
    exit(EXIT_FAILURE);
  }
  snprintf(op, 5, "%s", line);
}

int extract_value(char *line, size_t len) {
  size_t val_len = len - 5;
  if (val_len <= 0) {
    exit(EXIT_FAILURE);
  }
  char strval[val_len];
  snprintf(strval, val_len, "%s", line + 5);
  int val = atoi(strval);
  return val;
}

void compile(char *file, Instruction *instructions, int *instr_len) {
  FILE *fp;
  char *line = NULL;
  size_t len = 0;
  size_t line_len = 0;

  int i = 0;
  fp = fopen(file, "r");
  while ((line_len = getline(&line, &len, fp)) != -1) {
    if (line_len >= 4) {
      char op[5];
      extract_op(line, op, line_len);

      if (strcmp(op, "noop") == 0) {
        instructions[i++] = (Instruction) {
          .code = 0,
          .value = 0
        };
      } else if (strcmp(op, "addx") == 0) {
        int val = extract_value(line, line_len);

        instructions[i++] = (Instruction) {
          .code = 1,
          .value = val
        };
        instructions[i++] = (Instruction) {
          .code = 2,
          .value = 0
        };
      } else {
        exit(EXIT_FAILURE);
      }
    }
  }
  *instr_len = i;

  fclose(fp);
  if (line) {
    free(line);
  }
}

void tick(State *state) {
  Instruction instr = state->instructions[state->pos];
  state->pos += 1;
  switch (instr.code) {
    case 0:
      break;
    case 1:
      state->y = instr.value;
      break;
    case 2:
      state->x += state->y;
      break;
  }
  state->counter += 1;
}

char ctr_pixel(State *state) {
  int x = state->x;
  int i = (state->counter - 1) % 40;
  if (i-1 <= x && x <= i+1) {
    return '#';
  } else {
    return '.';
  }
}

int main(void) {
  Instruction instructions[500];
  int len = 0;

  compile("input.txt", instructions, &len);

  State state = {
    .instructions = instructions,
    .counter = 1,
    .pos = 0,
    .x = 1,
    .y = 0
  };

  int signals[len];

  for (int i=0; i<len; i++) {
    signals[i] = state.counter * state.x;
    
    printf("%c", ctr_pixel(&state));
    if (state.counter % 40 == 0) {
      printf("\n");
    }

    tick(&state);
  }
  
  int a = 0;
  int cycles[] = {20, 60, 100, 140, 180, 220};
  for (int i=0; i<6; i++) {
    a += signals[cycles[i] - 1];
  }
  printf("\nA: %d\n", a);
}