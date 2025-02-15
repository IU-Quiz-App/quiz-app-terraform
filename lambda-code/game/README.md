# Object definition of a game session 

```json
{
  "uuid": "uuidSession123",
  "user_questions": [
    {
        "userUUID1": "uuidUser123",
        "questions": [
            {
                "question_uuid": "uuidQuestion",
                "course": "TestKurs",
                "answers": [],
                "requested_at": "2025-02-09T16:32:49.145446",
                "answered_at": "2025-02-09T16:32:49.145446",
                "given_answer": "uuidAnswer123"
            }	
        ]
    },
    {
        "userUUID1": "uuidUser123",
        "questions": [
            {
                "question_uuid": "uuidQuestion",
                "course": "TestKurs",
                "answers": [],
                "requested_at": "2025-02-09T16:32:49.145446",
                "answered_at": "2025-02-09T16:32:49.145446",
                "given_answer": "uuidAnswer123"
            }	
        ]
    }
  ],
  "courses": [
        "TestKurs",
        "TestKurs2"
  ],
  "game_session": "uuidGameSession123",	
  "created_at": "2025-02-09T16:32:49.145446",
  "started_at": "2025-02-09T16:32:49.145446",
  "ended_at": "2025-02-09T16:32:49.145446"
}
```