START   LDA ZERO     // Initialize for multiple program run
        STA RESULT
        STA COUNT
        INP          // User provided input
        BRZ END      // Branch to program END if input = 0
        STA VALUE    // Store input as VALUE
LOOP    LDA RESULT   // Load the RESULT
        ADD VALUE    // Add VALUE, the user provided input, to RESULT
        STA RESULT   // Store the new RESULT
        LDA COUNT    // Load the COUNT
        ADD ONE      // Add ONE to the COUNT
        STA COUNT    // Store the new COUNT
        SUB VALUE    // Subtract the user provided input VALUE from COUNT
        BRZ ENDLOOP  // If zero (VALUE has been added to RESULT by VALUE times), branch to ENDLOOP
        BRA LOOP     // Branch to LOOP to continue adding VALUE to RESULT
ENDLOOP LDA RESULT   // Load RESULT
        OUT          // Output RESULT
        BRA START    // Branch to the START to initialize and get another input VALUE
END     HLT          // HALT - a zero was entered so done!
RESULT  DAT          // Computed result (defaults to 0)
COUNT   DAT          // Counter (defaults to 0)
ONE     DAT 1        // Constant, value of 1
VALUE   DAT          // User provided input, the value to be squared (defaults to 0)
ZERO    DAT          // Constant, value of 0 (defaults to 0)
