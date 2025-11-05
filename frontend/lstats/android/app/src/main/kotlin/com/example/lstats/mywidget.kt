package com.example.lstats  // ✅ matches your app package

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import com.example.lstats.R  // make sure this import exists

class YourWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            // Get saved streak value from Flutter side
            val prefs = HomeWidgetPlugin.getData(context)
            val streak = prefs.getInt("streak", 0)

            // Update widget UI
            views.setTextViewText(R.id.streak_value, "$streak ")

            // Push update
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
