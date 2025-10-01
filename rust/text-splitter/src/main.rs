use std::fs::File;
use std::io::{self, Read, Write};
use std::path::PathBuf;
use serde::Serialize;
use clap::Parser;
use text_splitter::{ChunkCapacity, ChunkConfig, TextSplitter, MarkdownSplitter};
use tiktoken_rs::cl100k_base;

#[derive(Serialize)]
struct Chunk {
    text: String,
    start: usize,
    end: usize,
}

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Cli {
    /// Input file (default: stdin)
    #[arg(short, long)]
    input: Option<PathBuf>,

    /// Output file (default: stdout)
    #[arg(short, long)]
    output: Option<PathBuf>,

    /// Chunk capacity (e.g. "1000" or "500..1500")
    #[arg(long, default_value = "1000")]
    capacity: String,
    
    /// Chunk overlap (e.g. "20")
    #[arg(long, default_value = "20")]
    overlap: usize,

    /// Trim chunks (default: true)
    #[arg(long, default_value_t = true)]
    trim: bool,

    /// Use markdown splitter instead of plain text
    #[arg(long, default_value_t = false)]
    markdown: bool,
    
    /// Use tiktoken tokenizer
    #[arg(long, default_value_t = false)]
    tiktoken: bool,

}

fn parse_capacity(s: &str) -> Result<ChunkCapacity, String> {
    if let Some(pos) = s.find("..") {
        let start = s[..pos].parse::<usize>().map_err(|_| "Invalid start range".to_string())?;
        let end = s[pos + 2..].parse::<usize>().map_err(|_| "Invalid end range".to_string())?;
        Ok((start..end).into())
    } else {
        let n = s.parse::<usize>().map_err(|_| "Invalid capacity number".to_string())?;
        Ok(n.into())
    }
}

fn read_input(input: &Option<PathBuf>) -> io::Result<String> {
    let mut buffer = String::new();
    match input {
        Some(path) => {
            let mut f = File::open(path)?;
            f.read_to_string(&mut buffer)?;
        }
        None => {
            io::stdin().read_to_string(&mut buffer)?;
        }
    }
    Ok(buffer)
}

fn write_output(output: &Option<PathBuf>, chunks: &[Chunk]) -> io::Result<()> {
    // Serialize chunks as JSON array
    let json = serde_json::to_string_pretty(&chunks)
        .map_err(|e| io::Error::new(io::ErrorKind::Other, e))?;

    match output {
        Some(path) => {
            let mut f = File::create(path)?;
            f.write_all(json.as_bytes())?;
        }
        None => {
            let mut out = io::stdout();
            out.write_all(json.as_bytes())?;
        }
    }
    Ok(())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();

    let capacity = parse_capacity(&cli.capacity).map_err(|e| format!("Capacity parse error: {}", e))?;

    let cfg = ChunkConfig::new(capacity).with_trim(cli.trim).with_overlap(cli.overlap)?;

    let text = read_input(&cli.input)?;
    
    let chunks: Vec<Chunk> = if cli.markdown {
        let splitter = MarkdownSplitter::new(cfg);
        splitter
            .chunks(&text)
            .map(|chunk| {
                let start = text.find(chunk).unwrap_or(0);
                let end = start + chunk.len();
                Chunk {
                    text: chunk.to_string(),
                    start,
                    end,
                }
            })
            .collect()        
    } else if cli.tiktoken {
        let splitter = TextSplitter::new(cfg.with_sizer(cl100k_base().unwrap()));        
        splitter
        .chunks(&text)
        .map(|chunk| {
            let start = text.find(chunk).unwrap_or(0);
            let end = start + chunk.len();
            Chunk {
                text: chunk.to_string(),
                start,
                end,
            }
        })
        .collect()
    } else {
        let splitter = TextSplitter::new(cfg);
        splitter
            .chunks(&text)
            .map(|chunk| {
                let start = text.find(chunk).unwrap_or(0);
                let end = start + chunk.len();
                Chunk {
                    text: chunk.to_string(),
                    start,
                    end,
                }
            })
            .collect()
    };


    write_output(&cli.output, &chunks)?;

    Ok(())
}
