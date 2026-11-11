import React, { useEffect, useState } from "react";
import { createRoot } from "react-dom/client";
import "./style.css";

const API = import.meta.env.VITE_API_URL || "";

function App() {
  const [tasks, setTasks] = useState([]);
  const [stats, setStats] = useState({ total: 0, todo: 0, in_progress: 0, done: 0 });
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [filter, setFilter] = useState("all");
  const [error, setError] = useState("");

  async function load() {
    try {
      const suffix = filter === "all" ? "" : `?status=${filter}`;
      const [taskRes, statsRes] = await Promise.all([
        fetch(`${API}/api/tasks${suffix}`), fetch(`${API}/api/stats`)
      ]);
      if (!taskRes.ok || !statsRes.ok) throw new Error("API request failed");
      setTasks(await taskRes.json());
      setStats(await statsRes.json());
      setError("");
    } catch {
      setError("Cannot reach the API. Check that the backend and database are running.");
    }
  }

  useEffect(() => { load(); }, [filter]);

  async function addTask(e) {
    e.preventDefault();
    if (!title.trim()) return;
    const response = await fetch(`${API}/api/tasks`, {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title: title.trim(), description, status: "todo" })
    });
    if (!response.ok) { setError("Could not create task."); return; }
    setTitle(""); setDescription(""); await load();
  }

  async function updateStatus(task, status) {
    await fetch(`${API}/api/tasks/${task.id}`, {
      method: "PATCH", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ status })
    });
    await load();
  }

  async function removeTask(id) {
    await fetch(`${API}/api/tasks/${id}`, { method: "DELETE" });
    await load();
  }

  return <main className="shell">
    <header><div><p className="eyebrow">WORKSPACE</p><h1>Task Manager</h1><p className="sub">Plan clearly. Execute consistently.</p></div><span className="api-pill">● API connected</span></header>
    <section className="stats">
      {[["All tasks", stats.total], ["To do", stats.todo], ["In progress", stats.in_progress], ["Completed", stats.done]].map(([label, value]) =>
        <article className="stat" key={label}><span>{label}</span><strong>{value}</strong></article>)}
    </section>
    <section className="panel">
      <h2>Create a task</h2>
      <form onSubmit={addTask} className="create-form">
        <input value={title} onChange={e => setTitle(e.target.value)} placeholder="What needs to be done?" maxLength="160" required />
        <input value={description} onChange={e => setDescription(e.target.value)} placeholder="Description (optional)" maxLength="2000" />
        <button type="submit">Add task</button>
      </form>
    </section>
    <section className="list-head"><div><h2>Your tasks</h2><p className="sub">Manage your team's work</p></div>
      <select value={filter} onChange={e => setFilter(e.target.value)}>
        <option value="all">All statuses</option><option value="todo">To do</option><option value="in_progress">In progress</option><option value="done">Completed</option>
      </select>
    </section>
    {error && <p className="error">{error}</p>}
    <section className="tasks">
      {tasks.length === 0 && !error ? <p className="empty">No tasks yet. Create your first task above.</p> :
        tasks.map(task => <article className="task" key={task.id}>
          <div className="task-copy"><strong>{task.title}</strong><p>{task.description || "No description"}</p></div>
          <select aria-label={`Status for ${task.title}`} value={task.status} onChange={e => updateStatus(task, e.target.value)}>
            <option value="todo">To do</option><option value="in_progress">In progress</option><option value="done">Completed</option>
          </select>
          <button className="delete" onClick={() => removeTask(task.id)} aria-label={`Delete ${task.title}`}>Delete</button>
        </article>)}
    </section>
    <footer>Task Manager · Built for the AWS DevOps assignment</footer>
  </main>;
}

createRoot(document.getElementById("root")).render(<App />);
