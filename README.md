SocialGenius
============

Putting Names to Faces

Adapted from the original program by Rob Faludi. This game is normally installed on a screen in the main hallway of ITP at the beginning of each school year.

### Setup

This program expects there to be a file called `matchdata.csv` inside the **data** folder, as well as a folder called **images** of all students.

#### Matchdata

The `matchdata.csv` is expected to consist of one row per student with the form:

```
NETID,FIRST,LAST,PREFERRED_FIRST,PREFERRED_LAST,YYYY
```

The best way to get this CSV is to talk to ITP's tech staff.

#### Images

Once you've got the `matchdata.csv` check out [this repository](https://github.com/itpresidents/directory) to automate downloading of the student images.
