
import sys
import os

def replace_lines(file_path, start_line, end_line, new_content):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    start_idx = start_line - 1
    end_idx = end_line
    
    new_lines = [line + '\n' for line in new_content.split('\n')]
    lines[start_idx:end_idx] = new_lines
    
    with open(file_path, 'w', encoding='utf-8', newline='') as f:
        f.writelines(lines)

# This content matches the structure required to close the widget tree properly
closure_content = """                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }"""

file_path = r"d:\Projelerim\qr-sayfa\lib\screens\qr_generator_screen.dart"
# Replacing lines 739 to 758 (approx the end of the build method)
replace_lines(file_path, 739, 758, closure_content)
print("Closures fixed.")
