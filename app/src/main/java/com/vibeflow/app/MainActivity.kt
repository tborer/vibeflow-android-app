package com.vibeflow.app

import android.app.Activity
import android.content.ContentValues.TAG
import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.widget.Button
import androidx.activity.result.ActivityResultLauncher
import android.widget.TextView
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import android.net.Uri
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import com.google.ai.client.generativeai.GenerativeModel
import kotlinx.coroutines.launch
import com.vibeflow.app.BuildConfig
import androidx.lifecycle.lifecycleScope
import java.io.IOException

class MainActivity : AppCompatActivity() {

    private val extractedTexts = mutableListOf<String>()
    private var selectedImageUris: List<Uri> = emptyList()
    private lateinit var selectImageButton: Button
    private lateinit var pickImageLauncher: ActivityResultLauncher<Intent>
    private lateinit var imageView: ImageView
    private lateinit var resultTextView: TextView
    private lateinit var progressBar: ProgressBar
    private var processedCount = 0
    private lateinit var generativeModel: GenerativeModel


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        pickImageLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
            if (result.resultCode == Activity.RESULT_OK && result.data != null) {
                resultTextView.text = "" // Clear previous text
                imageView.setImageURI(null) // Clear previous image
                val data: Intent? = result.data
                // Handle multiple selected images
                if (data.clipData != null) {
                    selectedImageUris = (0 until data.clipData!!.itemCount).map {
                        data.clipData!!.getItemAt(it).uri
                    }.take(5) // Limit to 5 images
                    processSelectedImages()
                } else if (data.data != null) {
                    // Handle single image selection for now, can be refined
                    val uri = data.data!!
                    processImageWithMLKit(uri)
                    imageView.setImageURI(uri)
                }
            }
        }

        // Initialize the GenerativeModel client.
        generativeModel = GenerativeModel(modelName = "gemini-pro", apiKey = BuildConfig.GEMINI_API_KEY)

        selectImageButton = findViewById(R.id.selectImageButton)
        imageView = findViewById(R.id.imageView)
        resultTextView = findViewById(R.id.resultTextView)
        progressBar = findViewById(R.id.progressBar) // Assuming the ProgressBar has the ID 'progressBar'

        selectImageButton.setOnClickListener {
            Log.d("MainActivity", "Button clicked")
            val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                type = "image/*"
                setAction(Intent.ACTION_OPEN_DOCUMENT)
                putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
            }
            pickImageLauncher.launch(intent)
        }
    }

    // Function to handle displaying recognized text (not needed for direct display)
    private fun displayRecognizedText(text: String) {
        // This function is now empty as we don't display extracted text directly
    }

    private fun processSelectedImages() {
        progressBar.visibility = ProgressBar.VISIBLE // Show progress bar
        extractedTexts.clear()
        processedCount = 0
        selectedImageUris.forEach { uri ->
            processImageWithMLKit(uri)
        }
    }

    private fun onImageProcessingComplete() {
        // This function is called after each image is processed
        processedCount++
        if (processedCount == selectedImageUris.size) {
            // All images have been processed
            val jsonText = createJsonFromExtractedTexts(extractedTexts)
            Log.d(TAG, "Generated JSON: $jsonText")
            lifecycleScope.launch {
                progressBar.visibility = ProgressBar.GONE // Hide progress bar
                sendTextToGemini(jsonText)
            }

            // You might want to update UI here to indicate processing is done
            // and potentially show a consolidated view or message
        }
    }

    private fun processImageWithMLKit(uri: Uri) {
        try {
            val image = InputImage.fromFilePath(this, uri) // Corrected
            val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
            recognizer.process(image)
                .addOnSuccessListener { visionText ->
                    // Task completed successfully
                    val resultText = visionText.text
                    Log.d(TAG, "Text recognition successful for ${uri.lastPathSegment}: $resultText")
                    extractedTexts.add(resultText)
                    onImageProcessingComplete()
                }
                .addOnFailureListener { e ->
                    // Task failed with an exception
                    handleRecognitionError(e)
                    onImageProcessingComplete()
                }
        } catch (e: IOException) {
            e.printStackTrace()
            handleRecognitionError(e)
            onImageProcessingComplete()
        } catch (e: Exception) {
            e.printStackTrace()
            handleRecognitionError(e)
            onImageProcessingComplete()
        }
    }

    private fun createJsonFromExtractedTexts(texts: List<String>): String {
        val jsonMap = texts.mapIndexed { index, text ->
            "screenshot${index + 1}" to text
        }.toMap()
        return Json.encodeToString(jsonMap)
    }

    private fun handleRecognitionError(e: Exception) {
        Log.e(TAG, "Text recognition failed", e)
        Toast.makeText(this, "Text recognition failed: ${e.message}", Toast.LENGTH_SHORT).show()
    }

    private suspend fun sendTextToGemini(text: String) {
        try {
            val response = generativeModel.generateContent(text)
            resultTextView.text = response.text
        } catch (e: Exception) {
            Log.e(TAG, "Error sending text to Gemini API", e)
            Toast.makeText(this, "Gemini API call failed: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }
}
