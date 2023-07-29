package org.oggnalivecore.qt;

import android.os.Bundle;
import android.system.ErrnoException;
import android.system.Os;

import org.qtproject.qt5.android.bindings.QtActivity;

import java.io.File;

public class oggnaliveQtActivity extends QtActivity
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        final File oggnaliveDir = new File(getFilesDir().getAbsolutePath() + "/.oggnalive");
        if (!oggnaliveDir.exists()) {
            oggnaliveDir.mkdir();
        }

        super.onCreate(savedInstanceState);
    }
}
