# Room loads each database via Class.forName("<Name>_Impl"), so R8 must keep
# the generated classes and their names. Without this, WorkManager (pulled in
# by the AdMob SDK) crashes release builds on launch with
# "Failed to create an instance of androidx.work.impl.WorkDatabase".
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
