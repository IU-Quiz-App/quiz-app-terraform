Item:
Data objects, consisting of attributes (key - value) like a JSON object
{
  "question_id": "q123",
  "group": "history",
  "question_text": "Wer war der erste Bundeskanzler Deutschlands?",
  "wrong_answer_1": "Angela Merkel",
  "wrong_answer_2": "Helmut Kohl",
  "wrong_answer_3": "Gerhard Schröder",
  "correct_answer": "Konrad Adenauer",
  "creator_user_id": "user_789",
  "status": "public",
  "created_at": "2024-02-02T12:00:00Z"
}

Partition Key (=Hash Key):
- Primary Key (acts like a partition key)
- For questions the group is used as partition key

Sort Key (=Range Key):
- Sorts elements in a partition
- For questions the question_id is used as sort key

Primary Key:
- Consists of partition key and sort key

Global Secondary Index (GSI):
- Request data based on attributes that are not partition or sort key
- Every GSI has it's own partition and sort key